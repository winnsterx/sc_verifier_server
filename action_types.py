from enum import Enum
from typing import Any, Optional, List, Dict, Literal
from pydantic import BaseModel, Field


class ActionType(Enum):
    """Available actions for exploiting Ethernaut contracts"""

    DEPLOY = "deploy"  # Deploy attacker contract
    CALL = "call"  # Call contract function
    SEND_ETH = "send_eth"  # Send ETH to address
    READ_STORAGE = "read_storage"
    CHECK_WIN = "check_win"  # Check if level is solved
    GET_LEVEL_CONTEXT = "get_level_context"
    EXECUTE_ACTIONS = "execute_actions"


class DeployRequest(BaseModel):
    """Deploy a new smart contract

    Example:
    {
        "code": "pragma solidity ^0.8.0;\\ncontract Attacker { ... }",
        "contract_name": "Attacker",
        "constructor_args": ["0x123..."]
    }
    """

    code: str = Field(..., description="Solidity source code")
    contract_name: str = Field(..., description="Contract name without .sol extension")
    constructor_args: Optional[List[Any]] = Field(
        default=[], description="Constructor parameters"
    )
    value_wei: int = 0  # Add this field


class CallRequest(BaseModel):
    """Call a function on a deployed contract

    Examples:
    # Call instance function
    {
        "contract_file": "CoinFlip.sol",
        "contract_name": "CoinFlip",
        "contract_address": "$INSTANCE",  # Special variable
        "function_name": "flip",
        "function_args": [true],
        "is_view": false
    }

    # Read state
    {
        "contract_file": "CoinFlip.sol",
        "contract_name": "CoinFlip",
        "contract_address": "$INSTANCE",
        "function_name": "consecutiveWins",
        "function_args": [],
        "is_view": true
    }
    """

    contract_file: str = Field(..., description="Contract filename with .sol extension")
    contract_name: str = Field(..., description="Contract name for ABI lookup")
    contract_address: str = Field(
        ..., description="Target address or $INSTANCE/$FACTORY"
    )
    function_name: str = Field(..., description="Function to call")
    function_args: Optional[List[Any]] = Field(
        default=[], description="Function arguments"
    )
    value_wei: Optional[int] = Field(
        default=0, description="Wei to send (for payable functions)"
    )
    is_view: Optional[bool] = Field(
        default=False, description="True for read-only calls"
    )


class SendEthRequest(BaseModel):
    """Send ETH to an address

    Example:
    {
        "to_address": "$INSTANCE",
        "amount_wei": 1000000000000000  # 0.001 ETH
    }
    """

    to_address: str = Field(..., description="Recipient address or $INSTANCE")
    amount_wei: int = Field(..., description="Amount in wei (1 ETH = 10^18 wei)")
    data: Optional[str] = Field(
        None, description="Optional transaction data (hex string)"
    )


class ReadStorageRequest(BaseModel):
    address: str
    slot: int


class EthernautAction(BaseModel):
    """Single action to perform"""

    action: ActionType
    params: Dict[str, Any]  # Will be validated based on action type
