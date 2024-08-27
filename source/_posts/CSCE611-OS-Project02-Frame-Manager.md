---
title: CSCE611-OS-Project02-Frame Manager
date: 2024-02-10 12:55:05
tags:
---

# CSCE611-OS-MP02-Frame-Manager

Github Link: https://github.com/tamu-edu-students/CSCE410-611-Spring2024-Hanzhong_Liu

Files I modified: 

- cont_frame_pool.H
- cont_frame_pool.C
- copykernel.sh
  - Modified to fit Mac OS
- makefile
  - Add a new item `make run` to make it easier to start the kernel
    ```makefile
    run: copy start_vm
    copy: 
    	./copykernel.sh
    start_vm:
    	bochs -f bochsrc.bxrc
    ```
  
    

### Memory Structure

**Design of memory pools:**

![mp2-frame-memory.drawio (1)](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/mp2-frame-memory.drawio.png)



**Design of the bitmap:**
I used two bits to store the status of a frame. The first bit indicates whether the frame is used and the second bit indicates whether the frame is the head of a frame sequence. So, we have the follows:

- `[0,x]` : Not Used (`x` is 0 or 1)
- `[1,1]` : Used and this frame is the head of a sequence
- `[1,0]` : Used and this frame is not the head of a sequence

![mp2-frame-bitmap.drawio](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/mp2-frame-bitmap.drawio.png)

### Get Frames

```c++
unsigned long ContFramePool::get_frames(unsigned int _n_frames);
```

- The function first determines if there are enough frames to allocate, then iterates through the bitmap, looking for appropriate frames, and returns the frame's id.



### Release Frames

```c++
void release_frames_internel(unsigned long _first_frame_no);

ContFramePool*        next_pool;  // next pool
static ContFramePool* pools_head; // head point of all polls
static void release_frames(unsigned long _first_frame_no);
```

- **`release_frames_internel`**: An internal function to release frames starting from a given frame number within a specific pool.
- **`next_pool`**: A pointer to the next memory frame pool, enabling a linked list structure for pool management.
- **`pools_head`**: A static pointer that serves as the head of the list of all memory frame pools.
- **`release_frames`**: A static function that releases frames by locating the correct pool using the frame's ID and then invoking `release_frames_internel` for that pool.



**Release process:**

- release_frames is a static function which has only one parameter `_first_frame_no`
- release_frames first determines which pool the frame belongs to, and then use `global_kernel_memory_pool` and `global_process_memory_pool ` to releases it.
- Since one sequence of frames needs to be released, the release process constantly determines whether a new head (Frame with `Used_Head` tag in bitmap) has been encountered. If so, the release_frames_internel will finish the release process and return.



### Output/Test

![Screenshot 2024-02-10 at 16.26.52](https://raw.githubusercontent.com/muchengl/pic_storage/main/uPic/Screenshot%202024-02-10%20at%2016.26.52.png)

