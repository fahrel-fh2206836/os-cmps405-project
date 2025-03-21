find /home/muhtasim/testDirectory -type f -perm 777 >> files_list.txt;	

#Change the Directory to root when executing in VM2

while read file; do
	chmod 700 "$file"
	echo "Changed permission of $file to 700" >> perm_changes.log
done < files_list.txt