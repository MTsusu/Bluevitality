>>> import hashlib
>>> encrypt=hashlib.sha512()
>>> encrypt.update(bytes('被加密的数据'))
>>> encrypt.hexdigest() 
'235f6fbc988cab61bf61b46d4de5e6465fe26605c332bcf805cedd3069dc520e57ee114f2a9b4b5dbbc44c5a92d039506c3e2a2ab22318164264ee71cac7dba8'
