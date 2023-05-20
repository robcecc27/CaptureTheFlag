#!/bin/bash

# Check if gcc is installed
if ! command -v gcc &> /dev/null
then
    # Install gcc
    if command -v yum &> /dev/null
    then
        sudo yum install gcc -y
    elif command -v apt-get &> /dev/null
    then
        sudo apt-get install gcc -y
    else
        echo "Unable to install gcc: Unsupported package manager"
        exit 1
    fi
fi

# Create a C file
echo -e '#include <stdio.h>\nint main() { printf("Congratulations, You Found the Binary File\\n(validation code = Lobo\\n"); return 0; }' > temp.c

# Compile the C file into a binary
gcc temp.c -o netconfig

# Remove the temporary C file
rm temp.c

# Create a text file
echo "Congratulations, You Found the text File Flag\nvalidation code = Mick & TreeFrog" > CHANGELOG

# Create a hidden file
echo "Congratulations, You Found the binary File Flag\nvalidation code = Rubix" > .sysconfig

# Get a list of root level directories
root_dirs=($(ls / | grep -vE "(dev|proc|sys|run|boot|bin|sbin|usr|lib|etc|root)"))

# Get a random root level directory and subdirectory for each file
for file in netconfig CHANGELOG .sysconfig; do
  success=0
  while [ $success -eq 0 ]; do
    root_dir=${root_dirs[$RANDOM % ${#root_dirs[@]}]}
    sub_dirs=($(ls -d /$root_dir/*/ 2>/dev/null))
    if [ ${#sub_dirs[@]} -eq 0 ]; then
      continue
    fi
    sub_dir=${sub_dirs[$RANDOM % ${#sub_dirs[@]}]}
    if [ -w $sub_dir ]; then
      # Try to move the file to the random directory
      mv $file $sub_dir && success=1
    fi
  done

  # Print the location of the file
  echo "File location: $sub_dir$file" >> /var/log/flag_planting.log
done
