UPDATE MasterSource
SET PublisherName = 'Ancestry.com Operations, Inc.', UpdateDate = strftime('%s','now')
WHERE PublisherName like '%Ancestry%Oper%';
/* need to update SyncVersion, too */



