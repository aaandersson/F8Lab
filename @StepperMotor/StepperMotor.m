classdef StepperMotor
    properties (SetAccess = private, Hidden)
        sp internal.Serialport
        ax uint8
    end
    methods
        %% CONSTRUCTOR
        function obj = StepperMotor(port,axis)
            assert(isscalar(port) && isstring(port))
            assert(isscalar(axis) && any(1:6 == axis))

            obj.sp = serialport(port,9600,"Timeout",1);
            obj.ax = axis;

            % 3.7.37 Request Target Position reached Event
            % byteString = encodeCommand(1,138,1,obj.ax,int32(2^obj.ax));
            % obj.writeread(byteString);
        end
        %% SETTERS
        function DefPosition(obj,pos)
            if nargin<2, pos = 0; end
            obj.Set("ActualPosition",int32(pos));
        end
        function success = ModPosition(obj,pos)
            oldpos = obj.GetPosition();
            success = obj.SetPosition(oldpos+pos);
        end
        function success = SeekLeftSwitch(obj,timeout)
            if nargin<3, timeout = 100; end
            obj.Set("ReferenceSearchMode",int32(1))
            % 3.7.13 Reference Search START
            byteString = encodeCommand(1,13,0,obj.ax,int32(0));
            obj.writeread(byteString);
            tic
            while toc<timeout
                % 3.7.13 Reference Search STATUS
                byteString = encodeCommand(1,13,2,obj.ax,int32(0));
                byteString = obj.writeread(byteString);
                [~,~,~,~,value] = decodeReply(byteString);
                if value==0
                    if nargout, success = true; end
                    return
                end
                java.lang.Thread.sleep(100)
            end
            % 3.7.13 Reference Search STOP
            byteString = encodeCommand(1,13,1,obj.ax,int32(0));
            obj.writeread(byteString);
            if nargout, success = false;
            else, warning("Time limit exceeded."), end
        end
        function Set(obj,param,value)
            param = checkAxisParameter(param,value);
            % 3.7.5 Set Axis Parameter
            byteString = encodeCommand(1,5,param,obj.ax,int32(value));
            obj.writeread(byteString);
        end
        function success = SetPosition(obj,pos,timeout)
            if nargin<3, timeout = 10; end
            % 3.7.4 Move to Position
            byteString = encodeCommand(1,4,0,obj.ax,int32(pos));
            obj.writeread(byteString);
            tic
            java.lang.Thread.sleep(50)
            while toc<timeout
%                 if obj.Get("RightLimitSwitchState") ...
%                     || obj.Get("LeftLimitSwitchState")
%                     % 3.7.3 Motor Stop
%                     byteString = encodeCommand(1,3,0,obj.ax,int32(0));
%                     obj.writeread(byteString);
%                     if nargout, success = false; 
%                     else, warning("Limit switch reached."), end
%                     return
%                 end
                if obj.Get("PostionReachedFlag")
                    if nargout, success = true; end
                    return
                end
                java.lang.Thread.sleep(5)
            end
            if nargout, success = false; 
            else, warning("Time limit exceeded."), end
        end
        %% GETTERS
        function value = Get(obj,param)
            param = checkAxisParameter(param);
            % 3.7.6 Get Axis Parameter
            byteString = encodeCommand(1,6,param,obj.ax,int32(0));
            reply = obj.writeread(byteString);
            [~,~,~,~,value] = decodeReply(reply);
        end
        function pos = GetPosition(obj)
            pos = obj.Get("ActualPosition");
        end
    end
    methods (Access = private)
        function write(obj,byteString)
            obj.sp.write(byteString,"uint8");
        end
        function byteString = read(obj)
            byteString = obj.sp.read(9,"uint8");
        end
        function byteString = writeread(obj,byteString)
            obj.sp.write(byteString,"uint8");
            byteString = obj.sp.read(9,"uint8");
        end
    end
end
% byteString = encodeCommand(module,command,type,motor,value)
% [replier,module,status,command,value] = decodeReply(byteString)
