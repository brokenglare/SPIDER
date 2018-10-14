%Pitest

Pip = '10.0.1.3'
LoP = '10.0.1.4'
Porto = 5005;

comms = comms();

comms.defineUDPObj('Alpha',LoP,5015,LoP,25001)
comms.defineUDPObj('RPI',Pip,5005,LoP,25002)
comms.defineUDPObj('RPIRx',Pip,52045,LoP,5006)

comms.openUDP('Alpha')
comms.openUDP('RPI')
comms.openUDP('RPIRx')

header = uint8(10);



c = 1;
manualMode = 0;
buttonOld = 0;
d = 0;

pirxp = comms.returnUDP('RPIRx')
while c
    data = comms.readVector('Alpha',8)
    if data(6) == uint8(16)
        c = 0;
    end
    if pirxp.bytesAvailable()
        d = comms.readVector('RPIRx',1)
        if d == uint8(16)
            manualMode = 1;
            comms.writeRaw('RPI',header)
        end
    end
    if data(6) == uint8(4) && buttonOld == uint8(0) && manualMode == 0
        manualMode = 1;
        comms.writeRaw('RPI',header)
        pause(.05);
    elseif data(6) == uint8(4) && buttonOld == uint8(0) && manualMode == 1
        manualMode = 0;
        comms.writeRaw('RPI',uint8(64));
        pause(.05);
    end
    if manualMode
        comms.writeRaw('RPI', [uint8(4); data])
    end
    %data = comms.readVector('Alpha',8)
    manualMode
    buttonOld = data(6);
        
    
end
comms.writeRaw('RPI',uint8(64));


comms.closeAll();