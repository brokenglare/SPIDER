classdef comms < handle
    %Skeleton communications class, seeing as I still don't have my old one
    %back
    
    properties
        UDPCell
        SerialCell
        LogCell
        Joy
        
        Axes
        Buttons
        Dpad
        
        oldAxes
        oldButtons
        oldDpad
    end
    
    methods(Static)
        
        function reset()
            disp('ALL CONNECTIONS RESET')
            instrreset
        end
        
    end
    
    methods
        
        function obj = comms()
            obj.UDPCell = {};
        end
        
        %GENERAL MAINTAINANCE FUNCTIONS /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
        
        %Opens all created Ports
        function openAll(obj)
            obj.openAllUDP();
            obj.openAllSerial();
        end
        
        %Closes all created Ports
        function closeAll(obj)
            obj.closeAllUDP();
            obj.closeAllSerial();
        end
        
        %SERIAL MAINTAINANCE FUNCTIONS /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
        
        %Define a Serial Object
        %Accepts varibles 
        function defineSerialObj(obj,name,varargin)
            t = obj.returnSerial(name)
            if t~= -1
                obj.closeSerial(name);
                act = obj.returnSerialInd(name);
                u = obj.buildSerialFromVariables(varargin);
                obj.SerialCell{act,2} = u;
                return
            end
            u = obj.buildSerialFromVariables(varargin);
            curcoms = size(obj.SerialCell);
            obj.SerialCell{curcoms(1)+1,1} = name;
            obj.SerialCell{curcoms(1)+1,2} = u;
        end
        
        %Term 1 com port, term 2 baud rate, term 3 parity
        function u = buildSerialFromVariables(~,varargin)
            varargin{1}
            varargin{2}
            if nargin == 1
                disp(varargin{1})
                u = serial((varargin{1}));
            elseif nargin == 2
                u = serial((varargin{1}),'BaudRate',varargin{2});
            elseif nargin == 3
                u = serial(char(varargin{1}),'BaudRate',varargin{2},'Parity',char(varargin{3}));
            else
                u = -1;
            end
        end
        
        %Return serial port object for the given name
        function com = returnSerial(obj, name)
            i = obj.returnSerialInd(name);
            if i == -1
                com = -1;
                return
            end
            com = obj.SerialCell{i,2};
        end
        
        %Return index of serial port object for the given name
        function ind = returnSerialInd(obj, name)
            vertl = size(obj.SerialCell);
            if vertl == [0 0]
                ind = -1;
                return;
            end
            for i = 1:vertl(1)
                if strcmp(obj.SerialCell{i},name)
                    ind = i;
                    break;
                end
            end
        end
        
        %Opens serial port object associated with given name
        %If none exist or already open, returns 0
        function success = openSerial(obj, name)
            com = obj.returnSerial(name);
            if com == -1 || strcmp(com.Status,'open')
                success = 0;
            else
                fopen(com);
                success = 1;
            end
        end
        
        %Close serial port object associated with given name
        %If none exist or already closed, returns 0
        function success = closeSerial(obj, name)
            com = obj.returnSerial(name);
            if com == -1 || strcmp(com.Status,'closed')
                success = 0;
            else
                fclose(com);
                success = 1;
            end
        end
        
        %Attempts to open all created Serial objects
        function openAllSerial(obj)
            vertl = size(obj.SerialCell);
            for i = 1:vertl(1)
               success =  obj.openSerial(obj.SerialCell{i,1});
               if success == -1
                   disp(['PORT ' obj.SerialCell{i,1} ' NOT OPENED'])
               end
            end
        end
        
        %Attempts to close all created Serial objects
        function closeAllSerial(obj)
            vertl = size(obj.SerialCell);
            for i = 1:vertl(1)
                success = obj.closeSerial(obj.SerialCell{i,1});
                if success == -1
                    disp(['PORT ' obj.SerialCell{i,1} 'NOT CLOSED'])
                end
            end
        end
        
        %UDP MAINTAINANCE FUNCTIONS /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
        
        %Define an UDP object.
        %Name, remote IP, remote Port, Local Port
        function defineUDPObj(obj,name,remoteIP,remotePort,localIP,localPort)
            t = obj.returnUDP(name);
            if t ~= -1
                obj.closeUDP(name);
                act = obj.returnUDPInd(name);
                u = udp(remoteIP,remotePort,'LocalHost',localIP,'LocalPort',localPort);
                obj.UDPCell{act,2} = u;
                return
            end
            u = udp(remoteIP,remotePort,'LocalPort',localPort);
            curports = size(obj.UDPCell);
            obj.UDPCell{curports(1)+1,1} = name;
            obj.UDPCell{curports(1)+1,2} = u;
        end
        
        %Return index of name referenced UDP object 
        function ind = returnUDPInd(obj, name)
            ind = -1;
            vertl = size(obj.UDPCell);
            if vertl == [0 0]
                ind = -1;
                return;
            end
            for i = 1:vertl(1)
                if strcmp(obj.UDPCell{i},name)
                    ind = i;
                    break;
                end
            end
        end
        
        %Return associated UDP object for a given name
        function udp = returnUDP(obj, name)
            vertl = size(obj.UDPCell);
            if vertl == [0 0]
                udp = -1;
                return
            end
            tempind = -1;
            for i = 1:vertl(1)
                if strcmp(obj.UDPCell{i},name)
                    tempind = i;
                    break;
                end
            end
            if tempind == -1
                udp = -1;
            else
                udp = obj.UDPCell{tempind,2};
            end
        end
        
        %Open UDP object associated with given name
        %If no port defined or port opened, return 0
        function success = openUDP(obj, name)
            udp = obj.returnUDP(name);
            if udp == -1 || strcmp(udp.Status,'open')
                success = 0;
            else
                fopen(udp);
                success = 1;
            end
        end
        
        %Close UDP port associated with given name
        %If no port defined or port cloed, return 0
        function success = closeUDP(obj, name)
            udp = obj.returnUDP(name);
            if udp == -1 || strcmp(udp.Status,'closed')
                success = 0;
            else
                success = 1;
                fclose(udp);
            end
        end
        
        %Attempts to open all defined UDP ports
        function openAllUDP(obj)
            vertl = size(obj.UDPCell);
            for i = 1:vertl(1)
               success =  obj.openUDP(obj.UDPCell{i,1});
               if success == -1
                   disp(['CONN ' obj.UDPCell{i,1} ' NOT OPENED'])
               end
            end
        end
        
        %Attempts to close all defined UDP ports
        function closeAllUDP(obj)
            vertl = size(obj.UDPCell);
            for i = 1:vertl(1)
                success = obj.closeSerial(obj.UDPCell{i,1});
                if success == -1
                    disp(['CONN ' obj.UDPCell{i,1} 'NOT CLOSED'])
                end
            end
        end
        
        %UDP COMMUNICATION FUNCTIONS /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
        
        %Writes data to a UDP port associated with a given name
        function writeVector(obj, name, inData)
            udp = obj.returnUDP(name);
            if udp == -1 || strcmp(udp.Status,'closed')
                return
            end
            fwrite(udp,typecast(double(inData), 'uint8'));
        end
        
        function writeRaw(obj, name, inData)
            udp = obj.returnUDP(name);
            if udp == -1 || strcmp(udp.Status,'closed')
                return
            end
            fwrite(udp, inData);
        end
        
        %Reads data from a UDP port associated with a given name
        function Data = readVector(obj, name, size)
            udp = obj.returnUDP(name);
            if udp == -1 || strcmp(udp.Status,'closed')
                return
            end
            Data = fread(udp,size);
            %Data = typecast(uint8(raw), 'double');
        end
        
        %SERIAL COMMUNICATION FUNCTIONS /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
        
        function writeSerial(obj, name, str)
            com = obj.returnSerial(name);
            if com == -1 || strcmp(com.Status,'closed')
                return
            end
            fprint(com,[str \n]);
        end
        
        function data = readSerial(obj, name)
            com = obj.returnSerial(name);
            if com == -1 || strcmp(com.Status,'closed')
                return
            end
            data = fread(com);
        end
        
        %JOYSTICK FUNCTIONS \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\
        
        function openJoystick(obj)
            obj.Joy = vrjoystick(1);
            [obj.Axes, obj.Buttons, obj.Dpad] = read(obj.Joy);
            obj.oldAxes = obj.Axes;
            obj.oldButtons = obj.Buttons;
            obj.oldDpad = obj.Dpad;
        end
        
        function UpdateJoy(obj)
            [axes, buttons, povs] = read(obj.Joy)
        end
        
        function closeJoystick(obj)
            close(obj.Joy)
        end
    end
end

