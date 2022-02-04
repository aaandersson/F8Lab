classdef StepperMotor
    properties (SetAccess = private, Hidden)
        ax uint8
        sp internal.Serialport
    end
    methods
        function obj = StepperMotor(port,axis)
            assert(isscalar(port))
            obj.ax = axis;
            assert(any(1:6 == obj.ax))
            obj.sp = serialport(port,9600,"Timeout",600);
            obj.sp.write(obj.comm_init(),"uint8");
            obj.sp.read(9,"uint8");
%             obj.SetMicrostepping(2);
%             obj.SetRunCurrent(147);
%             obj.SetStandByCurrent(147);
            %obj.EnableLimiters();
%             
        end
        function SetPosition(obj,pos)
            obj.sp.write(obj.comm_set_pos(pos),"uint8");
            obj.sp.read(9,"uint8");
            obj.sp.read(9,"uint8");
        end
        function pos = GetPosition(obj)
            obj.sp.write(obj.comm_get_pos(),"uint8")
            reply = obj.sp.read(9,"uint8");
            pos = 2^24*reply(5) + 2^16*reply(6) + 2^8*reply(7) + reply(8);
            if pos>=2^31, pos=pos-2^32; end
        end
        function SetRunCurrent(obj,n)
            %assert(0.05<=I&&I<=1.61)
            %n = round((I-0.05)/(1.61-0.05)*255);
            assert(0<=n&&n<=255)
            obj.sp.write(obj.comm_set_runcurr(n),"uint8");
            obj.sp.read(9,"uint8");
        end
        function SetStandByCurrent(obj,n)
            %assert(0.05<=I&&I<=1.61)
            %n = round((I-0.05)/(1.61-0.05)*255);
            assert(0<=n&&n<=255)
            obj.sp.write(obj.comm_set_stbcurr(n),"uint8");
            obj.sp.read(9,"uint8");
        end
        function SetMicrostepping(obj,pow2)
            errstr = "The microstep parameter must be a power of 2!";
            assert(1<=pow2&&pow2<=256,errstr)
            n = log2(pow2);
            assert(mod(n,1)==0,errstr)
            obj.sp.write(obj.comm_set_microstep(n),"uint8");
            obj.sp.read(9,"uint8");
        end
        function EnableLimiters(obj)
            obj.sp.write(obj.comm_set_switch(0),"uint8");
            obj.sp.read(9,"uint8");
        end
        function DisableLimiters(obj)
            obj.sp.write(obj.comm_set_switch(1),"uint8");
            obj.sp.read(9,"uint8");
        end
    end
    methods (Access = private)
        function bytes = comm_init(obj)
            % address=1, command=set mvp confirmation, option=always,
            % motor=axis
            bytes = helper(1,138,1,obj.ax,int32(2^obj.ax));
        end
        function bytes = comm_set_pos(obj,n)
            % address=1, command=MVP, option=ABS, motor=axis
            bytes = helper(1,4,0,obj.ax,int32(n));
            %bytes = helper(1,4,0,obj.ax+int32(64),int32(n)); interp
        end
        function bytes = comm_wait_pos(obj)
            % address=1, command=WAIT, option=POS, motor=axis
            bytes = helper(1,27,1,obj.ax,int32(0));
        end
        function bytes = comm_get_pos(obj)
            % address=1, command=GAP, option=actual pos, motor=axis
            bytes = helper(1,6,1,obj.ax,int32(0));
        end
        function bytes = comm_set_runcurr(obj,n)
            % address=1, command=SAP, option=max current ,motor=axis
            bytes = helper(1,5,6,obj.ax,int32(n));
        end
        function bytes = comm_set_stbcurr(obj,n)
            % address=1, command=SAP, option=standby current ,motor=axis
            bytes = helper(1,5,7,obj.ax,int32(n));
        end
        function bytes = comm_set_switch(obj,n)
            % address=1, command=SAP, option=run current ,motor=axis
            bytes = [ helper(1,5,12,obj.ax,int32(n))
                      helper(1,5,13,obj.ax,int32(n)) ];
        end
        function bytes = comm_set_microstep(obj,n)
            % address=1, command=SAP, option=run current ,motor=axis
            bytes = helper(1,5,140,obj.ax,int32(n));
        end
    end
    methods (Access = private, Static)
        function bytes = helper(ma,cn,tn,mn,val)
            bytes = zeros(9,1,"uint8");
            bytes(1:4) = uint8([ma,cn,tn,mn]);
            bytes(5)= uint8(bitand(bitshift(val,-24),255));
            bytes(6)= uint8(bitand(bitshift(val,-16),255));
            bytes(7)= uint8(bitand(bitshift(val,-8 ),255));
            bytes(8)= uint8(bitand(val              ,255));
            bytes(9)= uint8(bitand(sum(bytes(1:8))   ,255));
        end
    end
end