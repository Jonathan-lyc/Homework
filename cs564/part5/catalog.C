#include "catalog.h"
#include <stdlib.h>

RelCatalog::RelCatalog(Status &status) :
	 HeapFile(RELCATNAME, status)
{
// nothing should be needed here
}


const Status RelCatalog::getInfo(const string & relation, RelDesc &record)
{
	
	Status status = OK;
	Record rec;
	RID rid;
	//heapfile scan
	
	if (relation.empty()) return BADCATPARM;
	
	while (status == OK) 
	{
		// Open a scan on the relcat relation by invoking the startScan() method on itself. 
		HeapFileScan* hfs = new HeapFileScan(RELCATNAME, status);
		status = hfs->startScan(0, relation.length() + 1, STRING, relation.c_str(), EQ);
		// You want to look for the tuple whose first attribute matches the string relName. 
		// Then call scanNext() and getRecord() to get the desired tuple.
		status = hfs->scanNext(rid);
		
		status = hfs->getRecord(rec);
		// Finally, you need to memcpy() the tuple out of the buffer pool into the return parameter record.
		memcpy((void*)&record, rec.data, rec.length);
		return status;
	}
	if (status == FILEEOF)
	{
		return RELNOTFOUND;
	}
	return status;
}

// Adds the relation descriptor contained in record to the relcat relation.
const Status RelCatalog::addInfo(RelDesc & record)
{
	RID rid;
	Status status = OK;
	while (status == OK)
	{
		// First, create an InsertFileScan object on the relation catalog table
		InsertFileScan scan(RELCATNAME, status);
		
		// records getting stored wrong?
// 		int len = strlen(record.relName);
//   	memset(&record.relName[len], 0, sizeof(record.relName - len));
		
		// Next, create a record and then insert it into the relation catalog 
		// table using the method insertRecord of InsertFileScan. 
		Record r;
		r.data = & record;
		r.length = sizeof(RelDesc);
		status = scan.insertRecord(r, rid);
		break;
	}
	return status;
}

const Status RelCatalog::removeInfo(const string & relation)
{
	Status status = OK;
	RID rid;
	HeapFileScan* hfs;
	
	if (relation.empty()) return BADCATPARM;
	
	while (status == OK) 
	{
		hfs = new HeapFileScan(RELCATNAME, status);
		// you have to start a filter scan on relcat to locate the rid of the desired tuple.
		status = hfs->startScan(0, relation.length() + 1, STRING, relation.c_str(), EQ);
		
		status = hfs->scanNext(rid);
		// delete the record
		status = hfs->deleteRecord();   
		break;
	}
	if (status == NORECORDS)
	{
		return OK;
	}
	else if (status == FILEEOF)
	{
		return RELNOTFOUND;
	}
	else {
		return status;
	}
	
}


RelCatalog::~RelCatalog()
{
// nothing should be needed here
}


AttrCatalog::AttrCatalog(Status &status) :
	 HeapFile(ATTRCATNAME, status)
{
// nothing should be needed here
}

// Returns the attribute descriptor record for attribute attrName in relation relName. 
const Status AttrCatalog::getInfo(const string & relation, 
				  const string & attrName,
				  AttrDesc &record)
{

	Status status = OK;
	RID rid;
	Record rec;
	HeapFileScan*  hfs;
	hfs = new HeapFileScan(ATTRCATNAME, status);

	if (relation.empty() || attrName.empty()) return BADCATPARM;
	// Uses a scan over the underlying heapfile to get all tuples for relation 
	// and check each tuple to find whether it corresponds to attrName. 
	while (status == OK)
	{
		status = hfs->startScan(0, relation.length() + 1, STRING, relation.c_str(), EQ);
		while (hfs->scanNext(rid) != FILEEOF)
		{
			status = hfs->getRecord(rec);
			memcpy(&record, rec.data, rec.length);
			if (strcmp(record.attrName, attrName.c_str()) == 0)
			{
				// Break here?
				return status;
			}
		}
		break;
	}
	if (status == FILEEOF)
	{
		return ATTRNOTFOUND;
	}
	return status;

}


const Status AttrCatalog::addInfo(AttrDesc & record)
{
	
	RID rid;
	Status status = OK;
	while (status == OK)
	{
		// First, create an InsertFileScan object on the relation catalog table
		InsertFileScan scan(ATTRCATNAME, status);
		// Next, create a record and then insert it into the relation catalog 
		// table using the method insertRecord of InsertFileScan. 
		Record r;
		r.data = & record;
		r.length = sizeof(AttrDesc);
		status = scan.insertRecord(r, rid);
		break;
	}
	return status;

}


const Status AttrCatalog::removeInfo(const string & relation, 
			       const string & attrName)
{
	Status status = OK;
	Record rec;
	RID rid;
	AttrDesc record;
	HeapFileScan* hfs;
	
	if (relation.empty() || attrName.empty()) return BADCATPARM;

	while (status == OK) 
	{
		hfs = new HeapFileScan(ATTRCATNAME, status);
		// you have to start a filter scan on relcat to locate the rid of the desired tuple.
		status = hfs->startScan(0, relation.length() + 1, STRING, relation.c_str(), EQ);
		
		while (hfs->scanNext(rid) != FILEEOF)
		{
			status = hfs->getRecord(rec);
			memcpy(&record, rec.data, rec.length);
			if (strcmp(record.attrName, attrName.c_str()) == 0)
			{
				// Then you can call deleteRecord() to remove it
				status = hfs->deleteRecord();
				// break instead?
				return status;
			}
			  
		}
		break;
	}
	if (status == FILEEOF)
	{
		return status;
	}
	else if (status == NORECORDS)
	{
		return OK;
	}
	else {
		return status;
	}
}


const Status AttrCatalog::getRelInfo(const string & relation, 
				     int &attrCnt,
				     AttrDesc *&attrs)
{
	Status status = OK;
	RID rid;
	Record rec;
	HeapFileScan* hfs;
	hfs = new HeapFileScan(ATTRCATNAME, status);

	if (relation.empty()) return BADCATPARM;

// 	status = relCat->getInfo(relation,description);
// 	if (status != OK) {
// 		return status;
// 	}
// 	attrCnt = description.attrCnt;
// 	attrs = new AttrDesc[attrCnt];
	while (status == OK)
	{
		status = hfs->startScan(0, relation.length() + 1, STRING, relation.c_str(), EQ);
		attrCnt = 0;
		
		while (hfs->scanNext(rid) != FILEEOF)
		{
			status = hfs->getRecord(rec);
			attrCnt = attrCnt + 1;
			// First run through, create attrs.
			if (attrCnt == 1)
			{
				attrs = (AttrDesc*)(malloc(sizeof(AttrDesc)));
			}
			// Expand attrs
			else {
				attrs = (AttrDesc*)(realloc(attrs, attrCnt * sizeof(AttrDesc)));
			}
			memcpy(&attrs[attrCnt - 1], rec.data, rec.length);
		}
		break;
	}
	if (status == FILEEOF) {
		status = OK;
	}
// 	else if (attrCnt == 0)
// 	{
// 		return RELNOTFOUND;
// 	}
	else
	{
		return status;
	}

}


AttrCatalog::~AttrCatalog()
{
// nothing should be needed here
}

