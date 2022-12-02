# Welcome to the Project 
## 1. Clone Project

`git clone https://github.com/DamirSD673/project_1.git <dir_where_you_want_to_clone_to>`

## 2. Reconstruct the project
* Open Vivado GUI
* Open Vivado Terminal and find the path with cloned repo  
 `cd <path_with_tcl_file>`
* Run .tcl file with following command  
 `force <file>.tcl`  
Tip: Path to the .tcl file must only contain latin letters

 ## 3. Adding changes to git
 Source files should be saved in the sources **...__src_** folder
 * Block diagrams should be in **_bd_** folder
 * HDL sources should be in **_hdl_** folder
 * Constraints files should be in **_constraints_** folder
 * It's better to have new folder in **...__src_** folder for another files
 * New Custom/User IP-cores should be saved in **_ip_repo_** folder

 ## 4. Writing .tcl file
 With adding new files it's better to rerun the .tcl script
 * Open _File_->_Project_->_Write Tcl_
 * Rewrite Current .tcl file