#!/bin/bash

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
    sub_dirs=($(ls /$root_dir))
    sub_dir=${sub_dirs[$RANDOM % ${#sub_dirs[@]}]}

    # Try to move the file to the random directory
    mv $file /$root_dir/$sub_dir/ && success=1
  done

  # Print the location of the file
  echo "File location: /$root_dir/$sub_dir/$file" >> /var/log/flag_planting.log
done
