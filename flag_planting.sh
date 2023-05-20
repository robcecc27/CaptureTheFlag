#!/bin/bash

# Create a C file
echo -e '#include <stdio.h>\nint main() { printf("Congratulations, You Found the Binary File\\n(validation code = Lobo\\n"); return 0; }' > temp.c

# Compile the C file into a binary
gcc temp.c -o netconfig

# Remove the temporary C file
rm temp.c

# Create a text file
echo "Congratulations, You Found the text File Flag\nvalidation code = Mick & TreeFrog" > textfile.txt

# Create a hidden file
echo "Congratulations, You Found the binary File Flag\nvalidation code = Rubix" > .hiddenfile

# Get a list of root level directories
root_dirs=($(ls / | grep -vE "(dev|proc|sys|run|boot|bin|sbin|usr|lib|etc|root)"))

# Get a random root level directory
root_dir=${root_dirs[$RANDOM % ${#root_dirs[@]}]}

# Get a list of subdirectories in the root directory
sub_dirs=($(ls /$root_dir))

# Get a random subdirectory
sub_dir=${sub_dirs[$RANDOM % ${#sub_dirs[@]}]}

# Move the files to the random directory
mv netconfig /$root_dir/$sub_dir/
mv CHANGELOG /$root_dir/$sub_dir/
mv .sysconfig /$root_dir/$sub_dir/

# Print the locations of the files
echo "Binary file location: /$root_dir/$sub_dir/netconfig" >> /var/log/flag_planting.log
echo "Text file location: /$root_dir/$sub_dir/CHANGELOG" >> /var/log/flag_planting.log
echo "Hidden file location: /$root_dir/$sub_dir/.sysconfig" >> /var/log/flag_planting.log
