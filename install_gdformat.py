import platform
import subprocess
import sys

def install_gdformat():
    try:
        # Try running gdformat to check if it's installed
        subprocess.run(['gdformat', '--version'], check=True)
    except FileNotFoundError:
        # gdformat not found, determine OS and install using pip or pip3
        os_type = platform.system().lower()
        pip_command = 'pip' if os_type == 'windows' else 'pip3'

        try:
            subprocess.run([pip_command, 'install', 'gdtoolkit'], check=True)
            print("gdtoolkit installed successfully.")
        except subprocess.CalledProcessError as e:
            print(f"Error installing gdtoolkit: {e}")
            sys.exit(1)

if __name__ == "__main__":
    install_gdformat()
