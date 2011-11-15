/*
User1: Josh Day
username1: day
studentid1: 9040529886
User2: Josh Gachnang
username: gachnang
studentid2: 9040440803

Buf.c implements a buffer manager over the Minirel database system.
It is provides methods to allocate frames, pages, and read pages, unpin pages 
and flush pages back to disk.
*/


#include <memory.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>
#include <fcntl.h>
#include <iostream>
#include <stdio.h>
#include "page.h"
#include "buf.h"

#define ASSERT(c)  { if (!(c)) { \
		       cerr << "At line " << __LINE__ << ":" << endl << "  "; \
                       cerr << "This condition should hold: " #c << endl; \
                       exit(1); \
		     } \
                   }

//----------------------------------------
// Constructor of the class BufMgr
//----------------------------------------

BufMgr::BufMgr(const int bufs)
{
    numBufs = bufs;

    bufTable = new BufDesc[bufs];
    memset(bufTable, 0, bufs * sizeof(BufDesc));
    for (int i = 0; i < bufs; i++) 
    {
        bufTable[i].frameNo = i;
        bufTable[i].valid = false;
    }

    bufPool = new Page[bufs];
    memset(bufPool, 0, bufs * sizeof(Page));

    int htsize = ((((int) (bufs * 1.2))*2)/2)+1;
    hashTable = new BufHashTbl (htsize);  // allocate the buffer hash table

    clockHand = bufs - 1;
}

//Flushes out all dirty pages and deallocates the buffer pool and the BufDesc table.
BufMgr::~BufMgr() {

    // flush out all unwritten pages
    for (int i = 0; i < numBufs; i++) 
    {
        BufDesc* tmpbuf = &bufTable[i];
        if (tmpbuf->valid == true && tmpbuf->dirty == true) {

#ifdef DEBUGBUF
            cout << "flushing page " << tmpbuf->pageNo
                 << " from frame " << i << endl;
#endif

            tmpbuf->file->writePage(tmpbuf->pageNo, &(bufPool[i]));
        }
    }

    delete [] bufTable;
    delete [] bufPool;
}

/*
 * Allocate a free frame. Uses the clock algorithm to choose which frame to 
 * place the page in. 
 * 
 * Inputs:
 * int & frame: Used to return the address of the new frame.
 * 
 * Returns:
 * Status status: OK if everything went better than expected.
 *                BUFFEREXCEEDED if no room left in buffer pool for new frame
 *                UNIXERR if problem reading the underlying file
 */
const Status BufMgr::allocBuf(int & frame) 
{
    BufDesc *currptr;
    uint initPos = clockHand;
    bool bufferFull = true;
    
    // Go until we find free page or throw BUFFEREXCEEDED
    while(1) 
    {
        // Move the clock
        advanceClock();
        // Variable to reference which page the clock is pointed at
        currptr = &bufTable[clockHand];        
        // valid Set?
        if (currptr->valid == false) 
        {
            // An invalid page! Return it now! Will be valid after .Set()
            frame = currptr->frameNo;
            return OK;
        }
        // Check if page has been recently referenced
        if (currptr->refbit == true) 
        {
            // Clear refBit, we'll come back to this if no other pages are free
            currptr->refbit = false;
            // If page is now available, prevent BUFFEREXCEEDED
            if (currptr->pinCnt == 0) 
                bufferFull = false;
            // Move on to next page
            continue;
        }
        if (currptr->pinCnt > 0) 
        {
            if (bufferFull == true && clockHand == initPos)
                // If all other pages are pinned..nothing free.
                return BUFFEREXCEEDED;
            // Nothing to do here! Move on to next page
            continue;
        }
        // Dirty pages need to be written before being replaced
        if (currptr->dirty == true) 
        {
            // Flush Page to disk before giving to other process
            Status flushStatus = OK;
            flushStatus = currptr->file->writePage(currptr->pageNo,&bufPool[clockHand]);
            if (flushStatus != OK)
                return UNIXERR;
        }
        // Refbit was previously false, valid is true, and was flushed to disk
        // if necessary, Set frame to this frame, and return OK.
        frame = currptr->frameNo;
        hashTable->remove(currptr->file, currptr->pageNo);
        return OK;
    }
}

/*
 * Reads the page and returns it. If the page wasn't already in the pool, reads
 * it in from the disk and puts it into a free frame in the buffer pool. 
 * 
 * Inputs:
 * File* file: the file the pool is contained in.
 * const int PageNo: the page number of the page that needs to be read
 * Page*& page: a pointer to the actual page for reading. Used as a return.
 * 
 * Returns:
 * Status status: OK if everything went better than expected
 *                UNIXERR if there was a problem reading the pageNo
 *                BUFFEREXCEEDED if there is no room in the buffer
 *                HASHTBLERROR if the requested page couldn't be found in the 
 */
const Status BufMgr::readPage(File* file, const int PageNo, Page*& page)
{
    Status status = OK;
    int frameNo = -1;    
    // First check whether the page is already in the buffer pool by invoking the 
    // lookup() method on the hashtable to get a frame number.
    status = hashTable->lookup(file,PageNo,frameNo);
    if (status == OK)
    {
        //Page is in the buffer pool
        bufTable[frameNo].refbit = true;
        bufTable[frameNo].pinCnt = bufTable[frameNo].pinCnt + 1;
        page = &bufPool[frameNo];
        return OK;
    }
    else if (status == HASHNOTFOUND) 
    {
        //Page is not in buffer pool. 
        Status allocStatus = OK;
        allocStatus = allocBuf(frameNo);
        if (allocStatus == OK)
        {
            Status readPageStatus = OK;
            // Read the page from the buffer pool (adding to the pool if
            // necessary
            readPageStatus = file->readPage(PageNo,&bufPool[frameNo]);
            if (readPageStatus == OK) 
            {
                // Grab the page from the buffer pool
                page = &bufPool[frameNo];
                Status insertStatus = OK;
                // Insert the file into the hash table for fast lookups
                insertStatus = hashTable->insert(file,PageNo,frameNo);
                if (insertStatus == OK) 
                {
                    // Set up the file with proper ref/valid/dirty bits
                    bufTable[frameNo].Set(file,PageNo);
                    return OK;
                }
                else 
                    return HASHTBLERROR;
            }
            else 
                return UNIXERR;
        }
        else 
            return allocStatus;
        
    }
    // catch all because C++ requires it at the end of non void statements. :/
    return OK;
}

/*
 * Decrements the pinCnt of the given frame. Sets dirty bit if necessary.
 * 
 * Inputs:
 * File* file: the file the pool is contained in
 * const int PageNo: the page number in the buffer pool to unpin
 * 
 * Returns:
 * Status status: OK if everything went better than expected
 *                PAGENOTPINNED if the file had a zero pin count
 *                HASHNOTFOUND if the file isn't in the hash table
 * 
 */
const Status BufMgr::unPinPage(File* file, const int PageNo, 
			       const bool dirty) 
{
    Status status = OK;
    int frameNo = -1;
    // Find page in hashTable
    status = hashTable->lookup(file, PageNo, frameNo);
    if (status == OK)
    {
        // Make sure page was actually pinned before unpinning. Silly users.
        if (bufTable[frameNo].pinCnt <= 0) 
            return PAGENOTPINNED;
        bufTable[frameNo].pinCnt = bufTable[frameNo].pinCnt - 1;
        // Inform the buffer that this page has been updated and needs to go
        // to disk before being replaced.
        if (dirty == true) 
            bufTable[frameNo].dirty = true;
        return OK;
    }
    // If not in hashTable, shouldn't be in buffer
    else if (status == HASHNOTFOUND)
        return HASHNOTFOUND;
    // catch all because C++ requires it at the end of non void statements. :/
    return OK;
}

/*
 * Allocates an empty page, places it into a buffer pool frame, places it in the 
 * hash table for fast lookups, and sets the ref/valid/pin/dirty bits properly.
 * 
 * Inputs:
 * File* file: the file to allocate the new page in
 * int& pageNo: the page number of the new page in the buffer pool. 
 *    Used as a return.
 * Page*& page: a pointer to the actual page. Used as a return.
 * 
 * Returns:
 * Status status: OK if everything went better than expected. 
 *                HASHTBLERROR if couldn't be inserted into hash table
 *                UNIXERR if couldn't write to the file
 *                BUFFEREXCEEDED if buffer pool is full
 */
const Status BufMgr::allocPage(File* file, int& pageNo, Page*& page) 
{
//     Status status = OK;
    Status allocPageStatus = OK;
    Status allocBufStatus = OK;
    Status insertStatus = OK;
    // allocate an empty page in the specified file by invoking the file->allocatePage() method
    allocPageStatus = file->allocatePage(pageNo);
    if (allocPageStatus != OK) 
        return allocPageStatus;
    int frameNo = 0;
    // allocBuf() is called to obtain a buffer pool frame
    allocBufStatus = allocBuf(frameNo);
    if (allocBufStatus != OK) 
        return allocBufStatus;

    // an entry is inserted into the hash table
    insertStatus = hashTable->insert(file, pageNo, frameNo);
    if (insertStatus != OK) 
        return HASHTBLERROR;
    // Set() is invoked on the frame to set it up properly
    bufTable[frameNo].Set(file, pageNo);
    page = &bufPool[frameNo];
    return OK;
}

const Status BufMgr::disposePage(File* file, const int pageNo) 
{
    // see if it is in the buffer pool
    Status status = OK;
    int frameNo = 0;
    status = hashTable->lookup(file, pageNo, frameNo);
    if (status == OK)
    {
        // clear the page
        bufTable[frameNo].Clear();
    }
    status = hashTable->remove(file, pageNo);

    // deallocate it in the file
    return file->disposePage(pageNo);
}

const Status BufMgr::flushFile(const File* file) 
{
  Status status;

  for (int i = 0; i < numBufs; i++) {
    BufDesc* tmpbuf = &(bufTable[i]);
    if (tmpbuf->valid == true && tmpbuf->file == file) {

      if (tmpbuf->pinCnt > 0)
	  return PAGEPINNED;

      if (tmpbuf->dirty == true) {
#ifdef DEBUGBUF
	cout << "flushing page " << tmpbuf->pageNo
             << " from frame " << i << endl;
#endif
	if ((status = tmpbuf->file->writePage(tmpbuf->pageNo,
					      &(bufPool[i]))) != OK)
	  return status;

	tmpbuf->dirty = false;
      }

      hashTable->remove(file,tmpbuf->pageNo);

      tmpbuf->file = NULL;
      tmpbuf->pageNo = -1;
      tmpbuf->valid = false;
    }

    else if (tmpbuf->valid == false && tmpbuf->file == file)
      return BADBUFFER;
  }
  
  return OK;
}


void BufMgr::printSelf(void) 
{
    BufDesc* tmpbuf;
  
    cout << endl << "Print buffer...\n";
    for (int i=0; i<numBufs; i++) {
        tmpbuf = &(bufTable[i]);
        cout << i << "\t" << (char*)(&bufPool[i]) 
             << "\tpinCnt: " << tmpbuf->pinCnt;
    
        if (tmpbuf->valid == true)
            cout << "\tvalid\n";
        cout << endl;
    };
}


