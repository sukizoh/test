#!/bin/bash
username=sukizoh
credentials=( dd5ad494b4b185a43ae2a83b801d19fe3518acf575d5220565041b6e64ea7323)
vm_names=( vm-0.sukizoh.koding.kd.io)
vm_ids=( 531d095f268ee01a231e0268)
count=$((${#credentials[@]} - 1))
counter=0
clear
if [ -f /etc/koding/.kodingart.txt ]; then
  cat /etc/koding/.kodingart.txt
fi
echo
echo 'This migration assistant will help you move your VMs from the old Koding'
echo 'environment to the new one. For each VM that you have, we will copy your'
echo 'home directory from the old VM into a Backup directory on the new one.'
echo
echo 'Please note:'
echo '  - This script will copy changed files on the old VM and place them in '
echo '    the Backup directory of the new VM'
echo '  - This script will NOT install or configure any software'
echo '  - This script will NOT place any files outside your home directory.'
echo '    You will need to move those files yourself.'
echo '  - This script will NOT start any servers or configure any ports.'
echo
if [[ ${#vm_names[@]} -eq 1 ]]; then
  index=0
  confirm=''
  while true; do
    read -p "Do you wish to continue?" yn
    case $yn in
      [Yy]* ) break;;
      [Nn]* ) exit;;
      * ) echo "Please answer yes or no.";;
    esac
  done
else
  echo "Your VMs:"
  echo
  for vm in "${vm_names[@]}"; do
    echo " - [$counter] $vm"
    let counter=counter+1
  done
  echo
  index=''
  while [[ ! $index =~ ^[0-9]+$ || $index -ge $counter ]]; do
    echo -n "Which vm would you like to migrate? (0-$count) "
    read index
  done
fi
vm_name="${vm_names[$index]}"
echo
echo "Downloading files from $vm_name (this could take a while)..."
echo
archive="$vm_name.tgz"
status=$(echo "-XPOST -u $username:${credentials[$index]} -d vm=${vm_ids[$index]} -w %{http_code} --progress-bar --insecure https://migrate.sj.koding.com:3000/export-files" -o $archive | xargs curl)
echo "HTTP status: $status"
echo
if [[ $status -ne 200 ]]; then
  error=$(cat $archive)
  rm $archive
  echo "An error occurred: $error"
  echo
  echo "Migration failed. Try again or contact support@koding.com"
  echo
  exit 1
fi
echo "Extracting your files to directory $(pwd)/Backup/$vm_name..."
mkdir -p Backup/$vm_name
tar -xzvf $archive -C Backup/$vm_name --strip-components=1 > /dev/null
rm $archive
echo
echo "You have successfully migrated $vm_name to the new Koding environment."
echo "The files have been placed in /home/$username/Backup/$vm_name. Please use"
echo 'the unzip command to access the files and then move or copy them into the'
echo 'appropriate directories in your new VM.'
echo
