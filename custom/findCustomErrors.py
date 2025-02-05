import os
import re
import sys

def find_solidity_files(directory):
    """
    Find all Solidity files in the given directory and its subdirectories.
    """
    solidity_files = []
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith(".sol"):
                solidity_files.append(os.path.join(root, file))
    return solidity_files


def extract_custom_errors(file_path):
    """
    Extract custom error definitions from a Solidity file.
    """
    with open(file_path, "r") as file:
        content = file.read()

    # Regex to match custom error declarations
    error_pattern = r"error\s+([A-Za-z_][A-Za-z0-9_]*)\s*(\([^\)]*\))?\s*;"
    matches = re.findall(error_pattern, content)

    # Format matches into Solidity custom error definitions
    custom_errors = set()  # Use a set to avoid duplicates
    for match in matches:
        error_name = match[0]
        error_params = match[1] if match[1] else ""
        custom_errors.add(f"error {error_name}{error_params};")

    return custom_errors


def save_errors_to_contract(errors, output_file):
    """
    Save all collected errors into a Solidity contract.
    The contract name matches the output file name (excluding `.sol`).
    """
    # Extract contract name from the output file name
    contract_name = os.path.splitext(os.path.basename(output_file))[0]

    with open(output_file, "w") as file:
        # Add Solidity file header
        file.write("// SPDX-License-Identifier: UNLICENSED\n")
        file.write("pragma solidity ^0.8.28;\n\n")
        file.write(f"// Contract containing all collected custom errors\n")
        file.write("/* This file is generated automatically */\n\n")

        # Write the contract interface
        file.write(f"contract {contract_name} {{\n")
        for error in sorted(errors):  # Sort errors for consistent ordering
            file.write(f"    {error}\n")
        file.write("}\n")  # Close the contract


def main():
    """
    Main function to collect errors and save them into a contract.
    """
    # Check for command-line arguments
    if len(sys.argv) < 3:
        print("Usage: python3 script.py <solidity_directory> <output_file>")
        sys.exit(1)

    # Directory path is taken from the first command-line argument
    solidity_directory = sys.argv[1]

    # Output file path is taken from the second command-line argument
    output_file_path = sys.argv[2]

    if not os.path.isdir(solidity_directory):
        print(f"Error: The path '{solidity_directory}' is not a valid directory.")
        sys.exit(1)

    # Collect all Solidity files
    solidity_files = find_solidity_files(solidity_directory)
    if not solidity_files:
        print(f"No Solidity files found in the directory: {solidity_directory}")
        sys.exit(0)

    # Collect custom errors
    all_errors = set()  # Use a set to store all unique custom errors
    for solidity_file in solidity_files:
        errors = extract_custom_errors(solidity_file)
        all_errors.update(errors)  # Add new errors to the set

    # Save unique errors to a contract
    if all_errors:
        save_errors_to_contract(all_errors, output_file_path)
        print(f"Custom errors collected and saved in: {output_file_path}")
    else:
        print("No custom errors found in the provided directory.")


if __name__ == "__main__":
    main()
