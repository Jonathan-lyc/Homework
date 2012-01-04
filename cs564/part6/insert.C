/*
User1: Josh Day
username1: day
studentid1: 9040529886
User2: Josh Gachnang
username: gachnang
studentid2: 9040440803

Insert.c provides a function to allow you to perform insertions with queries.
*/
#include "catalog.h"
#include "query.h"
#include <stdlib.h>
#include <stdio.h>

/*
 * Inserts a record into the specified relation.
 *
 * Returns:
 * 	OK on success
 * 	an error code otherwise
 */
const Status QU_Insert(const string & relation, 
        const int attrCnt, 
        const attrInfo attrList[])
{
        Status status = OK;
        Record record;
        RID rid;
        int attrLen = 0;
        int len = 0;
        RelDesc relinfo;
        AttrDesc* attrinfo;

		// Obviously need an insert file scan
        InsertFileScan ifs(relation, status);
        if (status != OK) 
		{
			return status;
        }

		// Get the information and relation information about the given relation
        status = relCat->getInfo(relation, relinfo);
        if (status != OK) 
		{
			return status;
        }

        status = attrCat->getRelInfo(relation, attrLen, attrinfo);
        if (status != OK) 
		{
			return status;
        }
		// Find matching attrs, to get the lenth of the new record
        for (int i = 0; i < attrLen; i++) 
		{ 
			for (int j = 0; j < attrCnt; j++) 
			{ 
				if (strcmp(attrinfo[i].attrName, attrList[j].attrName) == 0) 
				{
					len = len + attrinfo[i].attrLen;
				}
			}
        }

		// Create array directly in record.
        record.data = (char*) malloc(len);
        record.length = len;
		
		// Find each attrValue, get the value at a string, and put it into data.
        for (int i = 0; i < attrCnt; i++) 
		{ 
			for (int j = 0; j < attrLen; j++)
			{ 
				if (strcmp(attrList[i].attrName, attrinfo[j].attrName) == 0) 
				{
					int type = attrinfo[j].attrType;
					if (type == INTEGER)
					{
						int val = atoi((char*)attrList[i].attrValue);
						memcpy((char*)record.data + attrinfo[j].attrOffset, &val, attrinfo[j].attrLen);
					}
					else if (type == FLOAT)
					{
						float val = atof((char*)attrList[i].attrValue);
						memcpy((char*)record.data + attrinfo[j].attrOffset, &val, attrinfo[j].attrLen);     
					}
					else
					{
						memcpy((char*)record.data + attrinfo[j].attrOffset, (char*)attrList[i].attrValue, attrinfo[j].attrLen - 1);
					}
				}
			}
        }
        // Insert the record!
        return ifs.insertRecord(record, rid);
}
