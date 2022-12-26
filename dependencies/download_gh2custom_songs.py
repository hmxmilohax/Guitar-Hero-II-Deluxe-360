# enable_keys.py
from pathlib import Path
import shutil
import os
try:
    import git
    print("module 'git' is installed. Downloading GH2 authored custom songs repo & enabling GH2 authored custom songs for Xenia, this may take some time.")
except ModuleNotFoundError:
    print("module 'git' is not installed. Install it via '/dependencies/install_gitpython.bat' or 'pip install gitpython'")
    sys.exit(1)
    
# get the current working directory
cwd = Path().absolute()

# clone/pull gh2-custom songs
gh2_custom_songs_source_path = cwd.joinpath("custom-songs/gh2-custom-songs")

if gh2_custom_songs_source_path.exists():
    # folder exists, pull the repository
    repo = git.Repo(gh2_custom_songs_source_path)
    origin = repo.remotes.origin
    origin.pull()
else:
    # folder does not exist, clone the repository
    repo = git.Repo.clone_from("https://github.com/hmxmilohax/gh2-customs.git", gh2_custom_songs_source_path, branch="ps2")

gh2_custom_songs_source_folder = cwd.joinpath("custom-songs/gh2-custom-songs/GH2CUSTOMSREPO/songs")
gh2_custom_config_source_folder = cwd.joinpath("custom-songs/gh2-custom-songs/GH2CUSTOMSREPO/config")
gh2_custom_customs_folder = cwd.joinpath("_xenia/content/415607E7/00000002/GH2CUSTOMSREPO/songs")
gh2_custom_custom_config_folder = cwd.joinpath("_xenia/content/415607E7/00000002/GH2CUSTOMSREPO/config")
files = os.listdir(gh2_custom_songs_source_path)

# Check if the destination folder exists
if os.path.exists(gh2_custom_customs_folder):
    # If it exists, remove it
    shutil.rmtree(gh2_custom_customs_folder)

# Copy the source folder to the destination
shutil.copytree(gh2_custom_songs_source_folder, gh2_custom_customs_folder, ignore_dangling_symlinks=False)

# Check if the destination folder exists
if os.path.exists(gh2_custom_custom_config_folder):
    # If it exists, remove it
    shutil.rmtree(gh2_custom_custom_config_folder)

# Copy the source folder to the destination
shutil.copytree(gh2_custom_config_source_folder, gh2_custom_custom_config_folder, ignore_dangling_symlinks=False)

# Delete all .vgs files
for path in gh2_custom_customs_folder.glob('**/*.vgs'):
    os.remove(path)

print(f"Successfully downloaded GH2 authored custom  songs. They will be available the next time you play.")