% See TMCM-6110 manual page 11.
% byteString = encodeCommand(module,command,type,motor,value)
function byteString = encodeCommand(module,command,type,motor,value)
byteString = zeros(1,9,"uint8");
byteString(1) = module;
byteString(2) = command;
byteString(3) = type;
byteString(4) = motor;
byteString(5) = uint8(bitand(bitshift(value,-24),255));
byteString(6) = uint8(bitand(bitshift(value,-16),255));
byteString(7) = uint8(bitand(bitshift(value,-08),255));
byteString(8) = uint8(bitand(bitshift(value,-00),255));
byteString(9) = uint8(bitand(sum(byteString)    ,255));
end