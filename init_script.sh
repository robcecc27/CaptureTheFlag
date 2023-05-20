#!/bin/bash

exec > >(tee /var/log/user-data.log) 2>&1

echo "Updating packages"
yum update -y || exit 1

echo "Installing gcc and httpd"
yum install gcc httpd -y || exit 1

echo "Creating webpage"
echo "<html><body><h1>Congratulations, You Found the Webpage! Validation Code = Treefrog</h1></body></html>" >/var/www/html/index.html || exit 1

echo "Starting httpd"
systemctl start httpd || exit 1

echo "Enabling httpd"
systemctl enable httpd || exit 1

# Create a C file
echo "Creating C file"
echo -e '#include <stdio.h>\nint main() { printf("Congratulations, You Found the Binary File! Validation code = Lobo"); return 0; }' > temp.c || exit 1

# Compile the C file into a binary
echo "Compiling C file"
gcc temp.c -o netconfig || exit 1

# Remove the temporary C file
echo "Removing temporary C file"
yes | rm temp.c || exit 1

# Create a text file
echo "Creating text file"
echo "Congratulations, You Found the text File Flag! Validation code = Mick" > CHANGELOG || exit 1

# Create a hidden file
echo "Creating hidden file"
echo "Congratulations, You Found the binary File Flag! Validation code = Rubix" > .sysconfig || exit 1

# Get a list of root level directories
echo "Getting list of root level directories"
root_dirs=($(ls / | grep -vE "(dev|proc|sys|run|boot|bin|sbin|usr|lib|etc|root)")) || exit 1

# Get a random root level directory and subdirectory for each file
echo "Moving files to random directories"
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
      mv $file $sub_dir && success=1 || exit 1
    fi
  done

  # Print the location of the file
  echo "File location: $sub_dir$file" >> /var/log/flag_planting.log
done
