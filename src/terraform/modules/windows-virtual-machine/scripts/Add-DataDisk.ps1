Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -DriveLetter F -UseMaximumSize
Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel DataDisk1 -Confirm:$false -Force
