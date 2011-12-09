#include "catalog.h"


const Status RelCatalog::createRel(const string & relation, 
				   const int attrCnt,
				   const attrInfo attrList[])
{
	Status status;
	RelDesc rd;
	AttrDesc ad;

	if (relation.empty() || attrCnt < 1)
		return BADCATPARM;

	if (relation.length() >= sizeof rd.relName)
		return NAMETOOLONG;

	// Should fail
	status == getInfo(relation, rd);
	if (status == OK)
	{
		return RELEXISTS;
	}
	
	// Search for duplicates. 
	int len = attrList[0].attrLen;
	for(int i = 1; i < attrCnt; i++) 
	{
		len = len + attrList[i].attrLen;
		for(int j = 0; j < i; j++)
		{
			if (strcmp(attrList[i].attrName, attrList[j].attrName) == 0) 
			{
				return DUPLATTR;
			}
		}
	}
	
	// Check from the email Fatemah sent out.
	if (len > PAGESIZE)
	{
		return ATTRTOOLONG;
	}
	// Fill in RelDesc
	strcpy(ad.relName, relation.c_str());
	rd.attrCnt = attrCnt;
	status = addInfo(rd);
	if (status != OK)
	{
		return status;
	}
	int offset = 0;
	// For each attribute, use addInfo
	for (int i = 0; i < rd.attrCnt; i++)
	{
// 		AttrDesc ad;
		// copy over, in order of appear
		strcpy(ad.attrName, attrList[i].attrName);
		ad.attrOffset = offset;
		ad.attrType = attrList[i].attrType;
		ad.attrLen = attrList[i].attrLen;
		offset = offset + attrList[i].attrLen;
		status = attrCat->addInfo(ad);
		if (status != OK) {
			// Should probably do some clean up here?
			return status;
		}
	}
		
	return createHeapFile(relation);



}

