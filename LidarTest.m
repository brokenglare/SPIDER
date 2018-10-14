%Robot Navigation Test
u = serial('COM4','BaudRate',115200)
fopen(u);
x = fread(u);

%attempt to decode packets