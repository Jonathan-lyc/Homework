#include "catalog.h"

//
// Destroys a relation. It performs the following steps:
//
// 	removes the catalog entry for the relation
// 	destroys the heap file containing the tuples in the relation
//
// Returns:
// 	OK on success
// 	error code otherwise
//

const Status RelCatalog::destroyRel(const string & relation)
{
	Status status = OK;

	if (relation.empty() || 
		relation == string(RELCATNAME) || 
		relation == string(ATTRCATNAME))
	return BADCATPARM;

	while (status == OK)
	{
		status = attrCat->dropRelation(relation);
		status = removeInfo(relation);
		status = destroyHeapFile(relation);
		return status;
	}
	return status;

}


//
// Drops a relation. It performs the following steps:
//
// 	removes the catalog entries for the relation
//
// Returns:
// 	OK on success
// 	error code otherwise
//

const Status AttrCatalog::dropRelation(const string & relation)
{
	Status status = OK;
	AttrDesc *attrs;
	int attrCnt;

	if (relation.empty()) return BADCATPARM;

	while (status == OK) {
		status = getRelInfo(relation, attrCnt, attrs);
		for (int i = 0; i < attrCnt; i++)
		{
			status = removeInfo(relation, attrs[i].attrName);
		}
		return status;
	}
	return status;

}


