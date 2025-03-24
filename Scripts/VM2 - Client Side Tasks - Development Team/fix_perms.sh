find /home/vm2dev/testDirectory -type f -perm 777 > files_list.txt;	

# Change the Directory to current user profile ~ when executing in VM2

# Create a directory with file to simulate this

while read file; do

	chmod 700 "$file"

	echo "Changed permission of $file to 700" >> perm_changes.log

	echo -e "\033[1;36mPermission of file $file has been changed to 700\033[0m"

done < files_list.txt
