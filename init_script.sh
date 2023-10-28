#!/bin/bash

exec > >(tee /var/log/user-data.log) 2>&1

echo "Updating packages"
yum update -y || exit 1

echo "Installing PHP"
yum install -y php || exit 1

echo "Installing gcc and httpd"
yum install gcc httpd -y || exit 1


# Create the webpage using PHP
cat <<- 'EOF' > /var/www/html/index.php
<html>
<body>
<h1>Congratulations, You Found the Webpage! Validation Code = "Attack or the Kittens"</h1>
<?php
  \$files = glob("/var/www/html/*.jpg");
  foreach (\$files as \$file) {
    echo '<img src="' . basename(\$file) . '" alt="Kitten">';
  }
?>
</body>
</html>
EOF


echo "Restarting httpd to apply PHP changes"
systemctl restart httpd || exit 1

echo "Enabling httpd"
systemctl enable httpd || exit 1

# Create a C file
echo "Creating C file"
echo -e '#include <stdio.h>\nint main() { printf("Congratulations, You Found the Binary File! Validation code = Lobo"); return 0; }' >temp.c || exit 1

# Compile the C file into a binary
echo "Compiling C file"
gcc temp.c -o netconfig || exit 1

# Remove the temporary C file
echo "Removing temporary C file"
rm -rf temp.c || exit 1

# Create a text file
echo "Creating text file"
echo "Congratulations, You Found the text File Flag! Validation code = Mick" >syslog_backup || exit 1

# Create a hidden file
echo "Creating hidden file"
echo "Congratulations, You Found the binary File Flag! Validation code = Rubix" >.sysconfig || exit 1

# Get a list of root level directories
echo "Getting list of root level directories"
root_dirs=($(ls / | grep -vE "(dev|proc|sys|run|boot|bin|sbin|usr|lib|etc|root)")) || exit 1

# Get a random root level directory and subdirectory for each file
echo "Moving files to random directories"
for file in netconfig syslog_backup .sysconfig; do
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
  echo "File location: $sub_dir$file" >>/var/log/flag_planting.log
done

# Creating scripts for traffic, memory, disk and DB load
echo "Creating Traffic Generation Script with random kittens"
cat <<- 'EOF' > /root/traffic_gen.sh
#!/bin/bash
while true; do
  width=$((100 + RANDOM % 800))
  height=$((100 + RANDOM % 800))
  curl -o "/var/www/html/kitten_${width}_${height}.jpg" "http://placekitten.com/${width}/${height}"
  sleep 10
done
EOF

echo "Creating Memory Eating Script"
cat <<- 'EOF' > /root/memory_eater.py
import time
large_list = []
while True:
  large_list.append('a' * 10240)
  time.sleep(1)
EOF

echo "Creating Disk Eating Script"
cat <<- 'EOF' > /root/disk_eater.sh
#!/bin/bash
while true; do
  dd if=/dev/zero of=/tmp/large_file bs=1M count=100 oflag=append conv=notrunc
  sleep 1
done
EOF

# Creating MySQL Database Write Script
echo "Creating MySQL Database Write Script"
cat <<- 'EOF' > /root/db_writer.py
import pymysql
import random
import time

# Connection details
db_params = {
  'host': 'localhost',
  'user': 'admin-user',
  'password': 'P@ssWord',
  'database': 'CaptureTheFlag'
}

conn = pymysql.connect(**db_params)
cursor = conn.cursor()

while True:
  cursor.execute("INSERT INTO table_name (column_name) VALUES (%s)", (random.randint(1, 100000),))
  conn.commit()
  time.sleep(1)
EOF


# Make scripts executable
chmod +x /root/traffic_gen.sh /root/disk_eater.sh

# Schedule scripts with cron
echo "Scheduling scripts with cron"
echo "* * * * * /usr/bin/bash /root/traffic_gen.sh" >> mycron
echo "* * * * * /usr/bin/python /root/memory_eater.py" >> mycron
echo "* * * * * /usr/bin/bash /root/disk_eater.sh" >> mycron
echo "* * * * * /usr/bin/python /root/db_writer.py" >> mycron
crontab mycron
rm mycron

# All Done
echo "All tasks completed"
