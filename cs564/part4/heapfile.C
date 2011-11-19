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
#include "heapfile.h"
#include "error.h"

/* This function creates an empty (well, almost empty) heap file
 * 
 * params: const string fileName
 *      name of the file to create the heapfile in.
 * returns: const Status status
 *      standard status return. OK if everything went well.
 */
const Status createHeapFile(const string fileName)
{
	File* 		file;
	Status 		status;
	FileHdrPage*	hdrPage;
    // ?????????????? Consistency!?!?!! header vs hdr. 
	int			hdrPageNo;
	int			newPageNo;
	Page*		newPage;

	// try to open the file. This should return an error
	status = db.openFile(fileName, file);
	if (status != OK)
	{
		// file doesn't exist. First create it and allocate
		// an empty header page and data page.
		status = OK;
        while (status == OK)
        {
            // To do this create a db level file by calling db->createFile()
            status = db.createFile(fileName);
            
            // And open it. Shouldn't fail this time.
            status = db.openFile(fileName, file); 

            // Need a page for the header
            status = bufMgr->allocPage(file, newPageNo, newPage);
            hdrPage = (FileHdrPage*) newPage;

            // Initialize
            hdrPageNo = newPageNo;
            const char* c_fileName = fileName.c_str();
            strcpy(hdrPage->fileName, c_fileName);
            hdrPage->pageCnt = 1;
            hdrPage->recCnt = 0;

            // Allocate and initialize a page for the first bit of data to eventually go in
            status = bufMgr->allocPage(file, newPageNo, newPage);
            newPage->init(newPageNo);

            // Build header pointers for linked list of pages
            hdrPage->firstPage = newPageNo;
            hdrPage->lastPage = newPageNo;

            // Unpin, mark as dirty (since we changed both)
            status = bufMgr->unPinPage(file, newPageNo, true);
            status = bufMgr->unPinPage(file, hdrPageNo, true);

            status = db.closeFile(file);
            // All's well that ends well. Return OK
            return OK;
        }
        db.closeFile(file);
        return status;
	}
	else
    {
		db.closeFile(file);
        return (FILEEXISTS);
	}

}

// routine to destroy a heapfile
const Status destroyHeapFile(const string fileName)
{
	return (db.destroyFile (fileName));
}

// constructor opens the underlying file
/* Constructor for a HeapFile. Opens the file on disk and sets up the header 
 * and first page.
 * 
 * params: const string & fileName
 *      The filename of the file the heap file will reside in
 * Status& returnStatus
 *      standard status return. OK if everything went well.
 * returns: returns through the returnStatus param.
 */
HeapFile::HeapFile(const string & fileName, Status& returnStatus)
{
	Status 	status;
	Page*	pagePtr;

	cout << "opening file " << fileName << endl;

	// Open the file and read in the header page and the first data page
    status = db.openFile(fileName, filePtr);
    if (status == OK) 
    {
        while (status == OK) 
        {
            // Get the header, and cast it as a header page.
            status = filePtr->getFirstPage(headerPageNo);
            status = bufMgr->readPage(filePtr, headerPageNo, pagePtr);            
            headerPage = (FileHdrPage*)pagePtr;
            
            // Set up the private data members.
            curPageNo = headerPage->firstPage;
            curRec = NULLRID;
            
            // Finally, if we can read the page in, everything is good.
            returnStatus = bufMgr->readPage(filePtr, curPageNo, curPage);
            return;
		}
		// Oh noes! An error! And we have a file open! Better shut that down quick.
		db.closeFile(filePtr);
		return;
	}
	else
	{
		cerr << "open of heap file failed\n";
		returnStatus = status;
		return;
	}
}

// the destructor closes the file
HeapFile::~HeapFile()
{
	Status status;
	cout << "invoking heapfile destructor on file " << headerPage->fileName << endl;

	// see if there is a pinned data page. If so, unpin it 
	if (curPage != NULL)
	{
		status = bufMgr->unPinPage(filePtr, curPageNo, curDirtyFlag);
		curPage = NULL;
		curPageNo = 0;
		curDirtyFlag = false;
		if (status != OK) cerr << "error in unpin of date page\n";
	}

	// unpin the header page
	status = bufMgr->unPinPage(filePtr, headerPageNo, hdrDirtyFlag);
	if (status != OK) cerr << "error in unpin of header page\n";

	// status = bufMgr->flushFile(filePtr);  // make sure all pages of the file are flushed to disk
	// if (status != OK) cerr << "error in flushFile call\n";
	// before close the file
	status = db.closeFile(filePtr);
	if (status != OK)
	{
		cerr << "error in closefile call\n";
		Error e;
		e.print (status);
	}
}

// Return number of records in heap file

const int HeapFile::getRecCnt() const
{
	return headerPage->recCnt;
}


/* This method returns a record (via the rec structure) given the RID of the 
 * record. The private data members curPage and curPageNo should be used to 
 * keep track of the current data page pinned in the buffer pool.
 * 
 * params: const RID & rid
 *      The rid to search for
 * Record & rec
 *      Actually the return value. The record pointed to by the RID
 * returns: const Status status
 *      Standard status return value. OK if everything went well.
 * 
 */
const Status HeapFile::getRecord(const RID &  rid, Record & rec)
{
	Status status = OK;
    while (status == OK) 
    {
        if (rid.pageNo == curPageNo)
        {
            // Record is on this page.
            status = curPage->getRecord(rid,rec);
            return status;
        }

        // Record is not on this page, get the page pointed to by the RID, after unpinning this one.
        status = bufMgr->unPinPage(filePtr, curPageNo, curDirtyFlag);
        status = bufMgr->readPage(filePtr, rid.pageNo,curPage);

        // Update the current pageNo.
        curPageNo = rid.pageNo;
        
        // Just read in the rid, should find the record now.
        status = curPage->getRecord(rid,rec);
        // Everything went better than expected.
        return OK;        
    }
    // Error!! Oh noes! No files opened here though.
    return status;
}

HeapFileScan::HeapFileScan(const string & name,
		Status & status) : HeapFile(name, status)
{
	filter = NULL;
}

const Status HeapFileScan::startScan(const int offset_,
		const int length_,
		const Datatype type_, 
		const char* filter_,
		const Operator op_)
{
	if (!filter_) {                        // no filtering requested
		filter = NULL;
		return OK;
	}

	if ((offset_ < 0 || length_ < 1) ||
			(type_ != STRING && type_ != INTEGER && type_ != FLOAT) ||
			(type_ == INTEGER && length_ != sizeof(int)
			 || type_ == FLOAT && length_ != sizeof(float)) ||
			(op_ != LT && op_ != LTE && op_ != EQ && op_ != GTE && op_ != GT && op_ != NE))
	{
		return BADSCANPARM;
	}

	offset = offset_;
	length = length_;
	type = type_;
	filter = filter_;
	op = op_;

	return OK;
}


const Status HeapFileScan::endScan()
{
	Status status;
	// generally must unpin last page of the scan
	if (curPage != NULL)
	{
		status = bufMgr->unPinPage(filePtr, curPageNo, curDirtyFlag);
		curPage = NULL;
		curPageNo = 0;
		curDirtyFlag = false;
		return status;
	}
	return OK;
}

HeapFileScan::~HeapFileScan()
{
	endScan();
}

const Status HeapFileScan::markScan()
{
	// make a snapshot of the state of the scan
	markedPageNo = curPageNo;
	markedRec = curRec;
	return OK;
}

const Status HeapFileScan::resetScan()
{
	Status status;
	if (markedPageNo != curPageNo) 
	{
		if (curPage != NULL)
		{
			status = bufMgr->unPinPage(filePtr, curPageNo, curDirtyFlag);
			if (status != OK) return status;
		}
		// restore curPageNo and curRec values
		curPageNo = markedPageNo;
		curRec = markedRec;
		// then read the page
		status = bufMgr->readPage(filePtr, curPageNo, curPage);
		if (status != OK) return status;
		curDirtyFlag = false; // it will be clean
	}
	else curRec = markedRec;
	return OK;
}

/* Scans through the heap file one page at a time. 
 * params: RID& outRid
 *      actually the return value. The next rid in the scan that satisfies the san predicate.
 * returns: uses outRid param as return
 * 
 */
const Status HeapFileScan::scanNext(RID& outRid)
{
	Status 	status = OK;
    Status  tmpStatus = OK;
	RID		nextRid;
	RID		tmpRid;
	int 	nextPageNo;
	Record      rec;
	bool first = false; // Track whethere this is the first time scanning the page or part of the sequence


	if (curRec.pageNo == -1)
    {
        // First scan, do some set up
        first = true; 
        nextPageNo = headerPage->firstPage;
        
	}
	else
    {
        // Scan in progress
        tmpRid = curRec;
        nextPageNo = tmpRid.pageNo;
	}
    status = OK;
    while (status == OK)
    {
        // Check if curPage has link to next page.
        while (nextPageNo > 0)
        {
            if (nextPageNo != curPageNo)
            {
                // Next page isn't the one currently pinned.
                // Unpin and read in new page.
                status = bufMgr->unPinPage(filePtr, curPageNo, curDirtyFlag);
                status = bufMgr->readPage(filePtr, nextPageNo, curPage);

                // Update private members appropriately for new page.
                curPageNo = nextPageNo;
                curDirtyFlag = false;
            }
            // Set things up for first run through.
            if (first)
            {
                // Avoid breaking the while loop for this..need to not just quit.
                if ((tmpStatus = curPage->firstRecord(tmpRid)) != OK)
                {
                    // Empty page, nothing to do here.
                    status = curPage->getNextPage(nextPageNo);
                    continue; // Go to next loop.
                }
                status = curPage->getRecord(tmpRid, rec);
                // Finally found the match! 
                if (matchRec(rec))
                {
                    // Store the rid in curRec and return curRec
                    curRec = tmpRid;
                    outRid = curRec;
                    return OK;
                }
            }

            // Again. avoid breaking while loop here with tmpStatus.
            // Get the next record on the page, avoiding invalid slots and checking to see if we are at the end of the page
            while ((tmpStatus = curPage->nextRecord(tmpRid, nextRid)) != ENDOFPAGE && tmpStatus != INVALIDSLOTNO)
            {
                tmpRid = nextRid;
                status = curPage->getRecord(tmpRid, rec);
                // Finally found the match!
                if (matchRec(rec))
                {
                    // Store the rid in curRec and return curRec
                    curRec = tmpRid;
                    outRid = curRec;
                    return OK;
                }
            }

            status = curPage->getNextPage(nextPageNo);
            first = true;
        }
    
        outRid = NULLRID; 
        status = FILEEOF;
    }
    return status;

}


// returns pointer to the current record.  page is left pinned
// and the scan logic is required to unpin the page 

const Status HeapFileScan::getRecord(Record & rec)
{
	return curPage->getRecord(curRec, rec);
}

// delete record from file. 
const Status HeapFileScan::deleteRecord()
{
	Status status;

	// delete the "current" record from the page
	status = curPage->deleteRecord(curRec);
	curDirtyFlag = true;

	// reduce count of number of records in the file
	headerPage->recCnt--;
	hdrDirtyFlag = true; 
	return status;
}


// mark current page of scan dirty
const Status HeapFileScan::markDirty()
{
	curDirtyFlag = true;
	return OK;
}

const bool HeapFileScan::matchRec(const Record & rec) const
{
    // no filtering requested
    if (!filter) return true;

    // see if offset + length is beyond end of record
    // maybe this should be an error???
    if ((offset + length -1 ) >= rec.length)
    return false;

    float diff = 0;                       // < 0 if attr < fltr
    switch(type) {

    case INTEGER:
        int iattr, ifltr;                 // word-alignment problem possible
        memcpy(&iattr,
               (char *)rec.data + offset,
               length);
        memcpy(&ifltr,
               filter,
               length);
        diff = iattr - ifltr;
        break;

    case FLOAT:
        float fattr, ffltr;               // word-alignment problem possible
        memcpy(&fattr,
               (char *)rec.data + offset,
               length);
        memcpy(&ffltr,
               filter,
               length);
        diff = fattr - ffltr;
        break;

    case STRING:
        diff = strncmp((char *)rec.data + offset,
                       filter,
                       length);
        break;
    }

    switch(op) {
    case LT:  if (diff < 0.0) return true; break;
    case LTE: if (diff <= 0.0) return true; break;
    case EQ:  if (diff == 0.0) return true; break;
    case GTE: if (diff >= 0.0) return true; break;
    case GT:  if (diff > 0.0) return true; break;
    case NE:  if (diff != 0.0) return true; break;
    }

    return false;
}

InsertFileScan::InsertFileScan(const string & name,
		Status & status) : HeapFile(name, status)
{
	//Do nothing. Heapfile constructor will bread the header page and the first
	// data page of the file into the buffer pool
}

InsertFileScan::~InsertFileScan()
{
	Status status;
	// unpin last page of the scan
	if (curPage != NULL)
	{
		status = bufMgr->unPinPage(filePtr, curPageNo, true);
		curPage = NULL;
		curPageNo = 0;
		if (status != OK) cerr << "error in unpin of data page\n";
	}
}

/* Inserts the record described by rec into the file returning the RID of the inserted record in outRid.
 * 
 * params: const Record & rec
 *          the record to be inserted
 * RID& outRid: the return value. The inserted record's rid.
 * 
 * returns: const Status status
 *      Standard status return. OK if everything went well.
 * 
 */
const Status InsertFileScan::insertRecord(const Record & rec, RID& outRid)
{
	Page*	newPage;
	int		newPageNo;
	Status	status;

	// check for very large records
	if ((unsigned int) rec.length > PAGESIZE-DPFIXED)
	{
		// will never fit on a page, so don't even bother looking
		return INVALIDRECLEN;
	}

	status = OK;
    while (status == OK)
    {
        // There is space on this page, so insert.
        if ((status = curPage->insertRecord(rec, outRid)) != NOSPACE)
        {
            headerPage->recCnt = headerPage->recCnt + 1;
            hdrDirtyFlag = curDirtyFlag = true; // Both are now dirty.
            return status;
        }

        // No room on current page. Get rid of current, get new page.
        status = bufMgr->unPinPage(filePtr, curPageNo, curDirtyFlag);
        status = bufMgr->allocPage(filePtr, newPageNo, newPage);
        // Initialize the new page. (shouldn't init just get a new page??)
        newPage->init(newPageNo);

        // Update private members to the new page.
        curPage = newPage;
        curPageNo = newPageNo;

        // Insertion should work now. Set dirty bit, since we just modified. 
        // Also update record count of this page.
        status = curPage->insertRecord(rec, outRid);
        curDirtyFlag = true;
        headerPage->recCnt = headerPage->recCnt + 1;

        // Standard linked list insertion technique from CS367.
        status = bufMgr->readPage(filePtr, headerPage->lastPage, newPage);
        status = newPage->setNextPage(newPageNo);
        status = bufMgr->unPinPage(filePtr, headerPage->lastPage, true);
        
        // Update header to reflect the insertion in the linked list.s
        headerPage->lastPage = newPageNo;
        headerPage->pageCnt = headerPage->recCnt + 1;
        hdrDirtyFlag = true;
        // All's well that ends well.
        return OK;
    }
    // Something went wrong. No files open.
    return status;
}


