import serial


serData = serial.Serial('/dev/ttyUSB0', 115200)

preSerInput = 0;
while(1):
    while serData.inWaiting() == 0:
        pass
    serInput = int(serData.readline().decode('utf-8'))
    InpB = ' '.join([b for b in bin(serInput)[2:].zfill(8)])
    bitChg = " ".join([' ' if b == '0' else '1' for b in bin(serInput^preSerInput)[2:].zfill(8)])
    preSerInput = serInput
    print(F"\t{serInput}\t{InpB}\t{bitChg}")
