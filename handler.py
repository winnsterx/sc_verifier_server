import uvicorn
import os
from pathlib import Path
from typing import List, Dict, Any
import argparse
from contextlib import asynccontextmanager
from fastapi import FastAPI
from eth_defi.provider.anvil import launch_anvil
from eth_defi.foundry.forge import deploy_contract_with_forge
from eth_defi.hotwallet import HotWallet
from web3 import Web3
import json
import rlp
from eth_utils import to_checksum_address, keccak
from action_types import (
    DeployRequest,
    CallRequest,
    SendEthRequest,
    ActionType,
    EthernautAction,
    ReadStorageRequest,
)
from dotenv import load_dotenv

load_dotenv()

CONFIG = {
    "ANVIL_HARDFORK": "shanghai",
    "DEPLOYER_PRIVATE_KEY": os.environ.get("DEPLOYER_PRIVATE_KEY", ""),
    "CONTRACTS_ROOT": Path(os.environ.get("CONTRACTS_ROOT", "./contracts")).absolute(),
}

TASK_ID = None
ANVIL = None
W3 = None
DEPLOYER = None
LEVEL_INFO = None
SCRIPT_DIR = Path(__file__).parent.absolute()


@asynccontextmanager
async def lifespan(app: FastAPI):
    global ANVIL, W3, DEPLOYER

    ANVIL = launch_anvil(hardfork=CONFIG["ANVIL_HARDFORK"])
    print(f"1. Anvil launched on port {ANVIL.port}")
    print("-" * 50)

    W3 = Web3(Web3.HTTPProvider(f"{ANVIL.json_rpc_url}"))
    if W3.is_connected():
        print(f"2. W3 provider connected successfuly")
        print("-" * 50)
    else:
        print("W3 connection failed!")

    if CONFIG["DEPLOYER_PRIVATE_KEY"] == "":
        print("Failed to fetch Deployed Private Key from .env file")

    DEPLOYER = HotWallet.from_private_key(CONFIG["DEPLOYER_PRIVATE_KEY"])
    print(f"3. DEPLOYER started up successfully at {DEPLOYER.address}")
    print("-" * 50)

    await setup_level()

    yield

    ANVIL.close()
    print("Anvil shutted down")


async def setup_level():
    global W3, DEPLOYER, LEVEL_INFO

    gamedata_path = CONFIG["CONTRACTS_ROOT"] / "gamedata.json"
    with open(gamedata_path) as f:
        LEVEL_INFO = json.load(f)["levels"][TASK_ID]

    factory_path = (
        CONFIG["CONTRACTS_ROOT"] / "src" / "levels" / LEVEL_INFO["levelContract"]
    )
    instance_path = (
        CONFIG["CONTRACTS_ROOT"] / "src" / "levels" / LEVEL_INFO["instanceContract"]
    )

    factory_address, instance_address = await deploy_level(factory_path, instance_path)

    with open(instance_path) as instance_file:
        instance_source_code = instance_file.read()

    # Update level info
    LEVEL_INFO.update(
        {
            "factoryAddress": factory_address,
            "instanceAddress": instance_address,
            "deployerAddress": DEPLOYER.address,
            "instanceSourceCode": instance_source_code,
        }
    )

    print(f"✅ Level {TASK_ID}: {LEVEL_INFO["instanceContract"]} deployed successfully")
    print(f"   Factory: {factory_address}")
    print(f"   Instance: {instance_address}")


async def deploy_level(factory_path: Path, instance_path: Path):
    global W3, DEPLOYER, LEVEL_INFO

    DEPLOYER.sync_nonce(W3)
    factory_contract, tx_hash = deploy_contract_with_forge(
        web3=W3,
        project_folder=CONFIG["CONTRACTS_ROOT"],
        contract_file=f"levels/{factory_path.name}",  # relative to project_root
        contract_name=factory_path.stem,
        deployer=DEPLOYER,
    )

    receipt = W3.eth.wait_for_transaction_receipt(tx_hash)
    if receipt.status != 1:
        raise Exception(f"Factory deployment failed: {tx_hash.hex()}")

    DEPLOYER.sync_nonce(W3)

    try:
        instance_address = factory_contract.functions.createInstance(
            DEPLOYER.address
        ).call(
            {
                "from": DEPLOYER.address,
                "value": W3.to_wei(LEVEL_INFO["deployFunds"], "ether"),
            }
        )
        instance_address = W3.to_checksum_address(instance_address)

    except Exception as e:
        raise Exception(f"Simulation failed while calling createInstance(): {e}")

    tx = factory_contract.functions.createInstance(DEPLOYER.address).build_transaction(
        {
            "from": DEPLOYER.address,
            "gas": 5_000_000,
            "gasPrice": W3.eth.gas_price,
            "value": W3.to_wei(LEVEL_INFO["deployFunds"], "ether"),
        }
    )
    signed_tx = DEPLOYER.sign_transaction_with_new_nonce(tx)
    tx_hash = W3.eth.send_raw_transaction(signed_tx.rawTransaction)
    receipt = W3.eth.wait_for_transaction_receipt(tx_hash)

    if receipt.status != 1:
        raise Exception(f"Instance creation failed: {receipt}")

    return factory_contract.address, instance_address


def get_receipt_data(receipt):
    global W3  # Add this
    receipt_data = {
        "transactionHash": (
            receipt.transactionHash.hex()
            if hasattr(receipt.transactionHash, "hex")
            else str(receipt.transactionHash)
        ),
        "blockNumber": int(receipt.blockNumber),
        "gasUsed": int(receipt.gasUsed),
        "status": int(receipt.status),
        "contractAddress": receipt.contractAddress,
        "from": W3.to_checksum_address(receipt["from"]),  # Convert to checksum
        "to": (
            W3.to_checksum_address(receipt.to) if receipt.to else None
        ),  # Convert to checksum
    }
    # Make sure logs are also properly encoded
    if hasattr(receipt, "logs"):
        receipt_data["logs"] = []
        for log in receipt.logs:
            log_data = {
                "address": W3.to_checksum_address(log.address),  # Convert to checksum
                "topics": [
                    topic.hex() if hasattr(topic, "hex") else str(topic)
                    for topic in log.topics
                ],
                "data": log.data.hex() if hasattr(log.data, "hex") else str(log.data),
                "blockNumber": log.blockNumber,
                "transactionHash": (
                    log.transactionHash.hex()
                    if hasattr(log.transactionHash, "hex")
                    else str(log.transactionHash)
                ),
            }
            receipt_data["logs"].append(log_data)
    return receipt_data


def predict_contract_address(deployer: str, nonce: int) -> str:
    """Predict contract address for CREATE opcode"""
    from eth_utils import to_bytes

    encoded = rlp.encode([to_bytes(hexstr=deployer), nonce])
    return to_checksum_address(keccak(encoded)[12:])


app = FastAPI(
    lifespan=lifespan,
)


@app.get("/")
def read_root():
    return {"status": "ready"}


@app.post("/deploy")
def deploy_contract(request: DeployRequest):
    """
    takes in .sol file, deploys it from deployer addr with the constructor args on anvil
    returns contract instance address

    contract_name: [name].sol
    """
    if not request.contract_name:
        return {"error": "Contract name cannot be empty"}

    contract_name = request.contract_name.replace(".sol", "")
    contract_file = f"{contract_name}.sol"

    answer_root = Path("contracts/src/answers")
    answer_root.mkdir(parents=True, exist_ok=True)
    contract_path = answer_root / contract_file

    try:
        with open(contract_path, "w") as f:
            f.write(request.code)
    except Exception as e:
        return {"error": f"Failed to write {contract_file} to {contract_path}: e"}

    contracts_root = Path(os.environ.get("CONTRACTS_ROOT", "./contracts"))

    try:
        DEPLOYER.sync_nonce(W3)
        contract, tx_hash = deploy_contract_with_forge(
            web3=W3,
            project_folder=SCRIPT_DIR / contracts_root,
            contract_file=f"answers/{contract_file}",
            contract_name=contract_name,
            deployer=DEPLOYER,
            constructor_args=request.constructor_args,
            wait_for_block_confirmations=True,
        )

        print(
            f"{request.contract_name} deployed with tx_hash {tx_hash.hex()}, with contract: {contract.address}"
        )
        # Get deployment receipt for more info
        receipt = W3.eth.get_transaction_receipt(tx_hash)

        print(f"✅ {contract_name} deployed at {contract.address}")
        print(f"📦 Transaction: {tx_hash.hex()}")

        return {
            "success": True,
            "contract_name": contract_name,
            "contract_address": W3.to_checksum_address(
                contract.address
            ),  # Ensure checksum
            "tx_hash": tx_hash.hex() if isinstance(tx_hash, bytes) else str(tx_hash),
            "gas_used": int(receipt.gasUsed) if receipt.gasUsed else None,
            "block_number": int(receipt.blockNumber) if receipt.blockNumber else None,
            "file_size": len(request.code),
            "network": "anvil",
            "receipt": get_receipt_data(receipt),
        }
    except Exception as e:
        return {"error": f"Failed to deploy {contract_path}: {e}"}


def process_args(function_args):
    global W3
    processed_args = []
    if function_args is None or function_args == []:
        return processed_args

    for arg in function_args:
        if isinstance(arg, str):
            # Check if it's an Ethereum address (0x followed by 40 hex chars)
            # Handle both lowercase and checksum addresses
            if (arg.startswith("0x") or arg.startswith("0X")) and len(arg) == 42:
                try:
                    # Always convert to checksum address for consistency
                    processed_args.append(W3.to_checksum_address(arg))
                except ValueError:
                    # Not a valid address, keep as string
                    processed_args.append(arg)
            # Only convert plain numeric strings (not hex)
            elif arg.isdigit():
                try:
                    processed_args.append(int(arg))
                except ValueError:
                    processed_args.append(arg)
            else:
                # Keep all other strings as-is
                processed_args.append(arg)
        else:
            processed_args.append(arg)

    return processed_args


@app.post("/call")
def call_contract_function(request: CallRequest):
    global W3, DEPLOYER
    contract_abi_root = Path("contracts/out/")
    abi_path = (
        contract_abi_root / f"{request.contract_file}" / f"{request.contract_name}.json"
    )

    try:
        with open(abi_path) as abi_file:
            abi = json.load(abi_file)["abi"]
    except FileNotFoundError:
        return {"error": f"ABI not found at {abi_path}"}

    contract_address = request.contract_address.strip()
    normalized_address = contract_address.lower()
    if not normalized_address.startswith("0x"):
        normalized_address = "0x" + normalized_address

    contract_instance = W3.eth.contract(
        address=W3.to_checksum_address(normalized_address), abi=abi
    )

    try:
        func = getattr(contract_instance.functions, request.function_name)
    except AttributeError:
        return {
            "error": f"Function {request.function_name} not found: {contract_instance}"
        }

    function_args = process_args(request.function_args)

    if request.is_view:
        try:
            result = func(*function_args).call()

            return {
                "result": result,
                "function_called": request.function_name,
                "function_args": request.function_args,
            }
        except Exception as e:
            return {
                "error": f"Error calling view function {request.function_name} with args {request.function_args}: {e}"
            }

    DEPLOYER.sync_nonce(W3)
    try:

        tx = func(*function_args).build_transaction(
            {
                "from": DEPLOYER.address,
                "gas": 1_000_000,
                "gasPrice": W3.eth.gas_price,
                "value": request.value_wei,
            }
        )
        signed = DEPLOYER.sign_transaction_with_new_nonce(tx)
        tx_hash = W3.eth.send_raw_transaction(signed.rawTransaction)
        receipt = W3.eth.wait_for_transaction_receipt(tx_hash)
        print("Receipts: ", receipt)

        logs = []
        try:
            for log in receipt.logs:
                try:
                    decoded = contract_instance.events[log.topics[0]].process_log(log)
                    logs.append(decoded)
                except:
                    log_dict = {
                        "address": log.address,
                        "topics": [
                            t.hex() if hasattr(t, "hex") else str(t) for t in log.topics
                        ],
                        "data": (
                            log.data.hex()
                            if hasattr(log.data, "hex")
                            else str(log.data)
                        ),
                        "blockNumber": log.blockNumber,
                        "transactionHash": (
                            log.transactionHash.hex()
                            if hasattr(log.transactionHash, "hex")
                            else str(log.transactionHash)
                        ),
                    }
                    logs.append(log_dict)
        except:
            pass
        return {
            "success": receipt.status == 1,
            "tx_hash": (tx_hash.hex() if isinstance(tx_hash, bytes) else str(tx_hash)),
            "gas_used": int(receipt.gasUsed) if receipt.gasUsed else None,
            "logs": logs,
            "function_called": request.function_name,
            "function_args": request.function_args,
        }

    except Exception as e:
        return {
            "error": f"Error calling non-view function {request.function_name} with args {request.function_args}: {e}"
        }


@app.post("/send-eth")
def send_eth(request: SendEthRequest):
    global W3, DEPLOYER
    try:
        print(f"send_eth called: to={request.to_address}, amount={request.amount_wei}")

        DEPLOYER.sync_nonce(W3)

        # Don't use .lower() on the address - this might break checksum
        checksum_address = W3.to_checksum_address(request.to_address)

        balance = W3.eth.get_balance(DEPLOYER.address)
        print(f"Deployer balance: {balance}, trying to send: {request.amount_wei}")

        if balance < request.amount_wei:
            return {
                "error": f"Insufficient balance. Have: {balance}, Need: {request.amount_wei}",
                "success": False,
            }

        tx = {
            "from": DEPLOYER.address,
            "to": checksum_address,
            "value": request.amount_wei,
            "gas": 300_000,
            "gasPrice": W3.eth.gas_price,
        }

        if request.data:
            tx["data"] = request.data

        signed = DEPLOYER.sign_transaction_with_new_nonce(tx)
        tx_hash = W3.eth.send_raw_transaction(signed.rawTransaction)
        receipt = W3.eth.wait_for_transaction_receipt(tx_hash)

        print(f"send_eth receipt status: {receipt.status}")
        print(
            f"send_eth to address balance after: {W3.eth.get_balance(checksum_address)}"
        )

        return {
            "tx_hash": tx_hash.hex() if hasattr(tx_hash, "hex") else str(tx_hash),
            "success": bool(receipt.status == 1),
            "data_sent": request.data if request.data else None,
            "gas_used": int(receipt.gasUsed) if receipt.gasUsed else None,
            "to": checksum_address,
        }
    except Exception as e:
        import traceback

        traceback.print_exc()
        return {"error": str(e), "success": False, "tx_hash": None}


@app.get("/check-win")
def check_win():
    global W3, DEPLOYER, LEVEL_INFO
    try:
        contract_abi_root = Path("contracts/out/")
        abi_path = (
            contract_abi_root
            / LEVEL_INFO["levelContract"]
            / f'{LEVEL_INFO["levelContract"].replace(".sol", "")}.json'
        )

        try:
            with open(abi_path) as abi_file:
                abi = json.load(abi_file)["abi"]
        except FileNotFoundError:
            return {"error": f"Factory ABI not found at {abi_path}"}

        factory_instance = W3.eth.contract(
            address=W3.to_checksum_address(LEVEL_INFO["factoryAddress"]), abi=abi
        )
        is_solved = factory_instance.functions.validateInstance(
            LEVEL_INFO["instanceAddress"], DEPLOYER.address
        ).call()

        return {
            "solved": is_solved,
            "level": TASK_ID,
            "instance": LEVEL_INFO["instanceAddress"],
            "player": DEPLOYER.address,
        }
    except Exception as e:
        return {"error": f"Failed to check win: {e}", "level": TASK_ID}


@app.post("/execute-actions")
def execute_actions(actions: List[Dict[str, Any]]):
    results = []

    try:
        for action in actions:
            action_type = action["action"]
            params = action["params"]
            if action_type == ActionType.DEPLOY:
                result = deploy_contract(DeployRequest(**params))
            elif action_type == ActionType.CALL:
                result = call_contract_function(CallRequest(**params))
            elif action_type == ActionType.SEND_ETH:
                result = send_eth(SendEthRequest(**params))
            elif action_type == ActionType.CHECK_WIN:
                result = check_win()
            elif action_type == ActionType.READ_STORAGE:
                result = read_storage()
            else:
                result = {"error": f"Unknown action type: {action_type}"}

            results.append({"action": action_type, "params": params, "result": result})
    except Exception as e:
        results.append({"action": action_type, "params": params, "result": str(e)})

    level_solved = False
    if actions[-1]["action"] == ActionType.CHECK_WIN:
        if results[-1]["solved"] == True:
            level_solved = True

    return {
        "n_actions_executed": len(results),
        "results": results,
        "level_solved": level_solved,
    }


@app.get("/level-context")
def get_level_context():
    global TASK_ID, LEVEL_INFO, W3, DEPLOYER
    """Get all context needed for solving the current level"""

    return {
        "level_id": TASK_ID,
        "level_name": LEVEL_INFO.get("name"),
        "instance_address": LEVEL_INFO.get("instanceAddress"),
        "factory_address": LEVEL_INFO.get("factoryAddress"),
        "deployer_address": DEPLOYER.address,
        "deployer_balance": W3.eth.get_balance(DEPLOYER.address),
        "instance_balance": W3.eth.get_balance(
            LEVEL_INFO.get("instanceAddress", "0x0")
        ),
        "available_contracts": {
            "instance": {
                "file": LEVEL_INFO.get("instanceContract"),
                "name": LEVEL_INFO.get("instanceContract", "").replace(".sol", ""),
            },
            # "factory": {
            #     "file": LEVEL_INFO.get("levelContract"),
            #     "name": LEVEL_INFO.get("levelContract", "").replace(".sol", ""),
            # },
        },
        "instance_source_code": LEVEL_INFO.get("instanceSourceCode", ""),
    }


@app.get("/read-storage")
def read_storage(request: ReadStorageRequest):
    try:
        global W3

        address = request.address
        slot = request.slot

        normalized_address = address.lower()
        if not normalized_address.startswith("0x"):
            normalized_address = "0x" + normalized_address

        checksum_address = W3.to_checksum_address(normalized_address)

        # Read storage at the specified slot
        storage_value_bytes = W3.eth.get_storage_at(checksum_address, slot)
        storage_value = storage_value_bytes.hex()
        bytes32_value = "0x" + storage_value[2:].zfill(64)

        return {
            "success": True,
            "address": checksum_address,
            "slot": slot,
            "raw_value": storage_value,
            "bytes32_value": bytes32_value,
            "decoded_values": {
                "uint256": int(storage_value, 16),
                "address": (
                    "0x" + storage_value[-40:] if len(storage_value) >= 40 else None
                ),
                "bool": bool(int(storage_value, 16)),
            },
        }
    except Exception as e:
        return {
            "success": False,
            "error": f"Failed to read storage: {str(e)}",
            "address": address,
            "slot": slot,
        }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PoCHandler Server")
    parser.add_argument("--task_id", type=int, default=3, help="Task ID of victim")
    parser.add_argument("--port", type=int, help="Port")
    args = parser.parse_args()
    TASK_ID = args.task_id
    port = args.port

    uvicorn.run(app, port=port)
