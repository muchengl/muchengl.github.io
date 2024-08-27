---
title: CSCE611-OS-Project07-File-System
date: 2024-05-03 13:56:39
tags:
---

### File System

**Introduction:** The File System (FS) described here is a simple implementation designed to manage files on a disk. It provides basic functionality such as mounting a disk, formatting it, creating, deleting, and looking up files by their IDs.

**FileSystem Class:** The `FileSystem` class is the central component of the file system implementation. It manages the disk, maintains the inode list, and keeps track of free blocks. Below are the details of its member functions:

1. **Constructor (`FileSystem::FileSystem()`):**

   - Initializes local data structures.
   - Does not connect to the disk yet.
   - Outputs a message indicating the construction of the file system.

2. **Destructor (`FileSystem::~FileSystem()`):**

   - Unmounts the file system if it has been mounted.
   - Ensures that the inode list and free block list are saved. Write inode list and free list to block0 and block1.

3. **Mount (`FileSystem::Mount(SimpleDisk\* _disk)`):**

   - Associates the file system with a disk.

   - Reads the inode list and the free block list into memory from the disk. In my file system, the first block is used to store inode list and second block is used for free list. In inode list, eack record contains two items, inode id and block id. Free is a bit map, ''*" in free list meas that `used` and "_" means that unused.
     

     <img src="https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-05-03%20at%2014.12.13.png" alt="图片替换文本" width="750" align="bottom" />

4. **Format (`FileSystem::Format(SimpleDisk\* _disk, unsigned int _size)`):**

   - Formats the disk, wiping any existing file system.
   - Populates the disk with an empty file system of the given size.
   - Initializes the inode list and the free block list.

5. **LookupFile (`FileSystem::LookupFile(int _file_id)`):**

   - Finds a file with the given ID in the file system.
   - Traverses the inode list to locate the file.
   - Returns the inode of the file if found; otherwise, returns null.
   - Outputs a message indicating the file lookup process.

6. **CreateFile (`FileSystem::CreateFile(int _file_id)`):**

   - Creates a file with the given ID in the file system.
   - Checks if the file already exists; if so, aborts and returns false.
   - Allocates a free block for the file and initializes its inode.
   - Adds the inode to the inode list.
   - Outputs a message indicating the file creation process.

7. **DeleteFile (`FileSystem::DeleteFile(int _file_id)`):**

   - Deletes a file with the given ID from the file system.
   - Checks if the file exists; if not, returns an error.
   - Frees the blocks occupied by the file and removes its inode from the inode list.
   - Outputs a message indicating the file deletion process.

**Inode Class:** The `Inode` class represents an index node in the file system. It contains information about a file, such as its ID and the block it occupies on the disk. Additional functions may be needed to read and store inodes from and to the disk.



### File

**Introduction:** The `File` class represents a file handle in the file system implementation. It provides functionality for sequential read and write operations on a file. Each `File` object maintains a reference to its corresponding inode in the file system.

**File Class:** Below are the details of the `File` class member functions:

1. **Constructor (`File::File(FileSystem\* _fs, int _id)`):**
   - Initializes the file handle with the provided file system reference (`_fs`) and file ID (`_id`).
   - Sets the current position to the beginning of the file.
   - Checks if the file exists in the file system by looking up its inode.
   - If the file does not exist, creates a new file with the provided ID.
   - Reads the file's data block into the block cache for sequential read and write operations.
2. **Destructor (`File::~File()`):**
   - Closes the file.
   - Writes any cached data to the disk.
3. **Read (`File::Read(unsigned int _n, char\* _buf)`):**
   - Reads `_n` characters from the file starting at the current position.
   - Copies the read characters into the buffer `_buf`.
   - Returns the number of characters read.
   - Does not read beyond the end of the file.
4. **Write (`File::Write(unsigned int _n, const char\* _buf)`):**
   - Writes `_n` characters to the file starting at the current position.
   - If the write extends over the end of the file, extends the length of the file until all data is written or until the maximum file size is reached.
   - Returns the number of characters written.
   - Does not write beyond the maximum length of the file.
5. **Reset (`File::Reset()`):**
   - Sets the current position to the beginning of the file.
   - Allows subsequent read or write operations to start from the beginning of the file.
6. **EoF (`File::EoF()`):**
   - Checks if the current position for the file is at the end of the file.
   - Returns true if the current position is at the end of the file; otherwise, returns false.
   - Helps determine if there are more characters to read from the file.



### Test

**Testing File System Functionality**

To ensure the proper functioning of the file system, the following steps are taken to test various operations:

1. **File Creation:**
   
   - Two files are created using the `CreateFile` function of the file system.
   - Assertions are used to verify that the files are successfully created.
     ```c++
     assert(_file_system->CreateFile(1));
     assert(_file_system->CreateFile(2));
     ```
   
     
   
2. **File Opening and Writing:**
   - The two files are "opened" using the `File` constructor, which initializes file handles.
   - Data is written to each file using the `Write` function, with different content for each file.
   - Assertions are used to verify that the write operations are successful.
     ```c++
     const char * STRING1 = "01234567890123456789";
     const char * STRING2 = "abcdefghijabcdefghij";
     ```
   
3. **File Closing:**
   - The files are automatically closed when they go out of scope.

4. **File Opening and Reading:**
   - The files are "opened" again to simulate reopening.
   - Data is read from each file using the `Read` function.
   - Assertions are used to compare the read data with the expected content.

5. **File Deletion:**
   
   - Both files are deleted using the `DeleteFile` function.
   - Assertions are used to verify that the files are successfully deleted.
   
8. **Comparison with Expected Results:**
   - The actual results of file read operations are compared with the expected content.
   - If any discrepancies are found, assertions will fail, indicating a potential problem with file reading or writing.

##### Log

```python
Hello World!
formatting disk
Write Block: 1	# init free list and inode list
Write Block: 2
mounting file system from disk
Read Block: 1 	# read free list and inode list
Read Block: 2
creating file with id:1

Created File Name: 1
Used File Block: 3

creating file with id:2

Created File Name: 2
Used File Block: 4

Opening file.	# open file21
looking up file with id = 1
Read Block: 3
Opening file. # open file 2
looking up file with id = 2
Read Block: 4
writing to file
writing to file
Closing file.
Write Block: 4
Closing file.
Write Block: 3

Opening file.	# open file again
looking up file with id = 1
Read Block: 3
Opening file.		# open file again
looking up file with id = 2
Read Block: 4
resetting file
reading from file
resetting file
reading from file
Closing file.
Write Block: 4
Closing file.
Write Block: 3
deleting file with id:1 # test passed 
File successfully deleted.
deleting file with id:2	# test passed 
File successfully deleted.

```





