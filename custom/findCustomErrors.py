import os
import re
import sys

def find_solidity_files(directory):
    """Find all Solidity files in the given directory and its subdirectories."""
    solidity_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".sol"):
                solidity_files.append(os.path.join(root, file))
    return solidity_files


def extract_custom_errors(file_path):
    """Extract custom error definitions from a Solidity file."""
    with open(file_path, "r") as file:
        content = file.read()

    # Regex to match custom error declarations
    error_pattern = r"error\s+([A-Za-z_][A-Za-z0-9_]*)\s*(\([^\)]*\))?\s*;"
    matches = re.findall(error_pattern, content)

    # Format matches into Solidity custom error definitions
    custom_errors = []
    for match in matches:
        error_name = match[0]
        error_params = match[1] if match[1] else ""
        custom_errors.append(f"error {error_name}{error_params};")

    return custom_errors


def save_errors_to_solidity_file(errors, output_file):
    """Save all collected errors to a single solidity file."""
    with open(output_file, "w") as file:
        # Add Solidity file header
        file.write("// SPDX-License-Identifier: UNLICENSED\n")
        file.write("pragma solidity ^0.8.10;\n\n")
        file.write("// All collected custom errors\n")
        file.write("/* This file is generated automatically */\n\n")
        file.write("import {IERC20} from \"openzeppelin5/token/ERC20/IERC20.sol\";\n\n")
        file.write("import {IERC4626} from \"openzeppelin5/interfaces/IERC4626.sol\";\n\n")
        for error in errors:
            file.write(f"{error}\n")


def main():
    """Main function to collect and save custom errors."""
    # Check for command-line arguments
    if len(sys.argv) < 2:
        print("Usage: python3 collect_errors.py <solidity_directory>")
        sys.exit(1)

    # Directory path is taken from the command-line argument
    solidity_directory = sys.argv[1]

    # Validate that the path exists
    if not os.path.isdir(solidity_directory):
        print(f"Error: The directory '{solidity_directory}' does not exist.")
        sys.exit(1)

    output_file_path = "../contracts/CollectedErrors.sol"

    # Find all Solidity files and extract custom errors
    solidity_files = find_solidity_files(solidity_directory)
    all_errors = []

    for solidity_file in solidity_files:
        errors = extract_custom_errors(solidity_file)
        all_errors.extend(errors)

    if all_errors:
        save_errors_to_solidity_file(all_errors, output_file_path)
        print(f"Custom errors collected and saved in: {output_file_path}")
    else:
        print("No custom errors found in the provided directory.")


if __name__ == "__main__":
    main()