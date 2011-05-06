#define T_DIR  1   // Directory
#define T_FILE 2   // File
#define T_DEV  3   // Special device
#define T_EXTENT 4 // Extent based file

struct stat {
  short type;  // Type of file
  int dev;     // Device number
  uint ino;    // Inode number on device
  short nlink; // Number of links to file
  uint size;   // Size of file in bytes
  //Block addresses, not to be confused with the urine holding body part.
  uint bladdrs[13]; //<- record address of every allocated block.
};

