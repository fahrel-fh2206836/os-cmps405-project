find /home/muhtasim/testDirectory -type f -perm 777 > files_list.txt;	

#Change the Directory to root when executing in VM2

while read file; do

	chmod 700 "$file"

	echo "Changed permission of $file to 700" >> perm_changes.log

	echo -e "\033[1;36mPermission of file $file has been changed to 700\033[0m"

done < files_list.txt
