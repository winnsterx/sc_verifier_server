#!/usr/bin/env python3
import json
import yaml
import os
from pathlib import Path

# Define the order of challenges as specified
CHALLENGE_ORDER = [
    "hello-world",
    "black-sheep", 
    "one-hundred-percent",
    "oven",
    "dai-plus-plus",
    "suspicious-charity",
    "token-locker",
    "grains-of-sand",
    "skill-based-game",
    "dragon-tyrant",
    "dodont",
    "enterprise-blockchain",
    "hopping-into-place",
    "free-real-estate",
    "dropper",
    "jotterp",
    "cosmic-radiation"
]

def load_challenge_yaml(challenge_dir):
    """Load and parse challenge.yaml file"""
    yaml_path = Path(challenge_dir) / "challenge.yaml"
    if yaml_path.exists():
        with open(yaml_path, 'r') as f:
            return yaml.safe_load(f)
    return None

def get_contract_files(challenge_dir):
    """Determine the appropriate contract files for the challenge"""
    # Check if it's a Solidity challenge
    deploy_path = Path(challenge_dir) / "challenge" / "project" / "script" / "Deploy.s.sol"
    challenge_sol_path = Path(challenge_dir) / "challenge" / "project" / "src" / "Challenge.sol"
    
    if deploy_path.exists() and challenge_sol_path.exists():
        return "Deploy.s.sol", "Challenge.sol"
    return "", ""

def generate_challenge_entry(challenge_name, deploy_id):
    """Generate a single challenge entry for gamedata.json"""
    base_dir = Path(__file__).parent
    challenge_dir = base_dir / challenge_name
    
    # Load challenge metadata
    challenge_data = load_challenge_yaml(challenge_dir)
    if not challenge_data:
        print(f"Warning: Could not load challenge.yaml for {challenge_name}")
        return None
    
    # Extract metadata from annotations
    annotations = challenge_data.get("metadata", {}).get("annotations", {})
    
    # Get contract files
    level_contract, instance_contract = get_contract_files(challenge_dir)
    
    # Determine difficulty based on order (0-indexed)
    difficulty = str(deploy_id)
    
    # Build the challenge entry
    entry = {
        "name": annotations.get("name", challenge_name),
        "type": annotations.get("type", "PWN"),
        "created": "2023-10-01",
        "difficulty": difficulty,
        "description": annotations.get("description", ""),
        "completedDescription": "",
        "levelContract": level_contract,
        "instanceContract": instance_contract,
        "revealCode": True,
        "deployParams": [],
        "deployFunds": 0,
        "deployId": str(deploy_id),
        "instanceGas": 1500000 if level_contract else 0,
        "author": annotations.get("author", ""),
        "tags": generate_tags(challenge_name, annotations),
        "flag": annotations.get("flag", "")
    }
    
    return entry

def generate_tags(challenge_name, annotations):
    """Generate appropriate tags for each challenge"""
    tags = []
    challenge_type = annotations.get("type", "")
    
    # Add type-based tags
    if challenge_type == "KOTH":
        tags.append("koth")
    
    # Add challenge-specific tags
    tag_mapping = {
        "hello-world": ["intro", "warmup"],
        "black-sheep": ["huff", "assembly"],
        "one-hundred-percent": ["payment", "splitter"],
        "oven": ["cryptography", "math"],
        "dai-plus-plus": ["defi", "stablecoin", "overflow"],
        "suspicious-charity": ["dex", "charity", "token"],
        "token-locker": ["uniswap", "liquidity", "locker"],
        "grains-of-sand": ["tokens", "fees"],
        "skill-based-game": ["randomness", "gambling"],
        "dragon-tyrant": ["evm", "nft", "game"],
        "dodont": ["initializer", "vulnerability"],
        "enterprise-blockchain": ["bridge", "multisig", "governance"],
        "hopping-into-place": ["bridge", "governance"],
        "free-real-estate": ["defi", "airdrop"],
        "dropper": ["airdrop"],
        "jotterp": ["solana", "rust"],
        "cosmic-radiation": ["ethereum"]
    }
    
    if challenge_name in tag_mapping:
        tags.extend(tag_mapping[challenge_name])
    
    return tags

def main():
    """Generate the gamedata.json file"""
    gamedata = {"levels": []}
    
    for idx, challenge_name in enumerate(CHALLENGE_ORDER):
        print(f"Processing {challenge_name}...")
        entry = generate_challenge_entry(challenge_name, idx)
        if entry:
            gamedata["levels"].append(entry)
    
    # Write the gamedata.json file
    output_path = Path(__file__).parent.parent.parent / "paradigm_2023_gamedata.json"
    with open(output_path, 'w') as f:
        json.dump(gamedata, f, indent=2)
    
    print(f"\nGenerated gamedata.json with {len(gamedata['levels'])} challenges")
    print(f"Output saved to: {output_path}")

if __name__ == "__main__":
    main()