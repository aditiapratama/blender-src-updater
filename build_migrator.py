# blender daily build migrator

import os, sys

CMD_OPEN = r"C:\Tools\b280.bat"  # batch file to launch blender from cmd
ADD_ONS = "ztest_matviz_280.py", "ztest_panel_280.py", "ztest_addon_280.py", "smart_select"

''' 
import re, zipfile
def extract_zip_and_rename_dir(fname):
	dname = ''
	with zipfile.ZipFile(fname, mode='r') as zf:
		nl = zf.namelist()
		dname = os.path.dirname(os.path.normpath(nl[0]))
		zf.extractall()
	print("\nDoes dir exist?")
	print(dname)
	print(os.path.isdir(dname))
	if os.path.isdir(dname):
		# blender-2.80-a1ae04d15a9f-win64.zip
		# blender-2.80.0-git.a1ae04d15a9f-windows64
		# blender-2.80-a1ae04d15a9f-win64
		srch_re = r"(blender-\d+\.\d+)(\.\d+.*\.)(.*)-windows64"
		repl_re = r"\1-\3-win64"
		new_dname = re.sub(srch_re, repl_re, dname)
		os.rename(dname, new_dname)
		#os.remove(r"/path/to/file.zip")  # remove zipped blender build?
		#os.removedirs(DIRECTORY)  # remove old blender build directory?
'''

def build_file_paths(root):
	global ADD_ONS
	addons_path = r"2.80\scripts\addons"
	return [os.path.join(root, addons_path, f) for f in ADD_ONS]


def all_files_exist(files, state):
	all_match_state = True
	#print("files:", files)  # debug
	for f in files:
		#print("f:", f, os.path.exists(f), state)  # debug
		if os.path.exists(f) is not state:
			print("Problem with:", f)
			all_match_state = False
	#print("all_match_state:", all_match_state)  # debug
	return all_match_state


def main():
	global CMD_OPEN
	if len(sys.argv) < 2:
		print("Error, missing path argument.")
		return
	elif len(sys.argv) > 2:
		print("Error, too many arguments.")
		print("Expected: 2,  Received: %d" % len(sys.argv))
		return
	new_base = sys.argv[1].strip()
	print("sys.argv[1]", sys.argv[1])
	if not os.path.isdir(new_base):
		print("Argument is not a valid directory:")
		print(sys.argv[1])
		return
	if not os.path.isfile(CMD_OPEN):
		print("Error, could not find file:")
		print(CMD_OPEN)
		return
	'''	'''
	cmd_str = ''
	with open(CMD_OPEN, 'r') as f:
		cmd_str = f.read().strip()

	#cmd_str = r"C:\Hardcoded\Path\to\daily\build\blender.exe"

	if not os.path.isfile(cmd_str):
		print("Error, could not find file:")
		print(cmd_str)
		#__import__('code').interact(local=dict(globals(), **locals()))  # debug
		return
	old_base, b_exe = os.path.split(cmd_str)
	old_addon_locs = build_file_paths(old_base)
	new_addon_locs = build_file_paths(new_base)
	if not all_files_exist(old_addon_locs, True):
		print("Error, could not find file(s).")
		return
	elif not all_files_exist(new_addon_locs, False):
		print("Error, name conflict in new directory.")
		return

	# create config directory
	config_dir = os.path.join(new_base, r"2.80\config")
	if not os.path.isdir(config_dir):
		#os.mkdir(config_dir)
		print("os.mkdir(config_dir)", config_dir)

	print("Migrating to", new_base)
	# rename path == move file/directory
	for i in range(len(old_addon_locs)):
		#os.rename(old_addon_locs[i], new_addon_locs[i])
		print("os.rename(\nOld_loc", old_addon_locs[i], "\nNew_loc", new_addon_locs[i])

	#if False:  # debug
	if not all_files_exist(new_addon_locs, True):
		print("Error, not all files moved to new directory.")
		return
	else:
		# create new cmd file to open new blender build from cmd line
		new_bat_str = os.path.join(new_base, b_exe)
		#with open(CMD_OPEN, 'w') as f:
		#	f.write(new_bat_str)
		print("CMD_OPEN:", CMD_OPEN)
		print("new_bat_str:", new_bat_str)

	'''
	exe --debug
	'''


main()
