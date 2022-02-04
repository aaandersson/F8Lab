% See TMCM-6110 manual page 12
% [replier,module,status,command,value] = decodeReply(byteString)
function [replier,module,status,command,value] = decodeReply(byteString)
replier = byteString(1);
module = byteString(2);
status = byteString(3);
command = byteString(4);
value = int64(byteString(5:8));
value = value(4) + 2^8*value(3) + 2^16*value(2) + 2^24*value(1) - 2^32*(value(1)>127);
value = int32(value);
end