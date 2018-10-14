function [data] = ReadFromLidar(port)
  d = 1;
  init_level = 0;
  e = 0;
  clf;
  hold off;
  plotmat = zeros(360,2);
  plottemp = zeros(2,2);
  while (d)
    if init_level == 0
      b = fread(port,1);
      if b == 250
        init_level = 1;
      else
        init_level = 0;
      end
    elseif init_level == 1
      b = fread(port,1);
      if b >= 160 && b <= 249
        index = b - 160;
        init_level = 2;
      else
        init_level = 0;
      end
    elseif init_level == 2
      %Speed
      e = 0;
      b_speed = fread(port,2);
          
      b_data0 = fread(port,4);
      b_data1 = fread(port,4);
      b_data2 = fread(port,4);
      b_data3 = fread(port,4);
      
      flushinput(port);

      [Ansmat(1,1) Ansmat(1,2)]= ProcessLidar(index * 4 + 0,b_data0);
      [Ansmat(2,1) Ansmat(2,2)]= ProcessLidar(index * 4 + 1,b_data1);
      [Ansmat(3,1) Ansmat(3,2)]= ProcessLidar(index * 4 + 2,b_data2);
      [Ansmat(4,1) Ansmat(4,2)]= ProcessLidar(index * 4 + 3,b_data3);
      
      for i = 2:2:4
          c = cos(Ansmat(i,1))*Ansmat(i,2);
          s = sin(Ansmat(i,1))*Ansmat(i,2);
          plotmat(round(Ansmat(i,1)*180/pi+.5),1) = c;
          plotmat(round(Ansmat(i,1)*180/pi+.5),2) = s;
          
      end
      j = 1;
      for i = 1:360
          if abs(plotmat(i,2)) >= 50
              plottemp(j,1:2) = plotmat(i,1:2);
              j = j+1;
          end
      end
      xlim([-3000 3000])
      ylim([-3000 3000])
      scatter(plotmat(1:360,1),plotmat(1:360,2),5,'filled','r')
      line(plottemp(1:length(plottemp),1),plottemp(1:length(plottemp),2));
      drawnow
      
      disp(Ansmat);



      init_level = 0;
    end
  end
end
