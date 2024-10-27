# Run this script to setup PyCall to run python in a local venv expected in quantlib/venv
# Currently the library is tested against python3.10.11
# Use also requirements.txt for the packages dependencies.
using Pkg
# Set the Python environment path relative to the project
ENV["PYTHON"] = joinpath(@__DIR__, "venv", "Scripts", "python")  # Windows
# ENV["PYTHON"] = joinpath(@__DIR__, "venv", "bin", "python.exe")  # macOS/Linux

# Rebuild PyCall to use the specified Python
Pkg.build("PyCall")