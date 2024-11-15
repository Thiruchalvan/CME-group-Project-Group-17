% Program to calculate the total size of Dam to account for entire year

Data = readmatrix("Data\DataPoints.xlsx");
[m,n] = size(Data);

% Converting the data for points to be compatible with days system
for i=1:n
    Data(1,i) = ((Data(1,i)-1)*30 + (30/2));
    Data(2,i) = Data(2,i)*24*3600;
    clear i;
end

% Approximating(Average) flow rate at the end points
Data_ = zeros(m,n+2);
Data_(1,n+2) = 366;
Data_(1:2,2:n+1) = Data;
[Data_(2,1),Data_(2,n+2)] = deal((Data(2,1) + Data(2,n))/2);

% Splitting the data based on step size dt
i=1;
j=1;
k=0;
NOD = 0;
dt = Data_(1,2) - Data_(1,1);
while i < n+2
    dt_ = Data_(1,i+1) - Data_(1,i);
    if j == 1
        partitions(3,1) = j;
    end
    if dt_ == dt
        DataSplited(1,j) = Data_(1, i);DataSplited(2,j) = Data_(2,i);
        j = j+1;
        NOD = NOD + 1;
    else
       DataSplited(1,j) = Data_(1,i);DataSplited(2,j) = Data_(2,i);
       k = k+1;
       partitions(1,k) = dt;
       partitions(2,k) = NOD;
       NOD = 0;
       j = j+2;
       DataSplited(1,j) = Data_(1,i);DataSplited(2,j) = Data_(2,i);
       partitions(3,k+1) = j;
       NOD = NOD + 1;
       j=j+1;
    end
    i = i+1;
    dt = dt_;
end
DataSplited(1,j) = Data_(1,i);DataSplited(2,j) = Data_(2,i);
k = k+1;
partitions(1,k) = dt;
partitions(2,k) = NOD;

% removing temporary varaibles
clear i;clear j;
clear k;clear NOD;

NOP = size(partitions,2);


integrations = zeros(1,NOP); % to store integration for each partition

% Integrating the data points based on number of segments
for i=1:NOP
    if partitions(2,i) == 1
        %apply trapezoidal Rule
        integrations(1,i) = (DataSplited(2,partitions(3,i)) ...
                               + DataSplited(2,partitions(3,i)+1))*partitions(1,i)/2;
    elseif mod(partitions(2,i),2) == 0 && mod(partitions(2,i),3) ~= 0
        %apply simpson's 1/3 rule
        int = 0;
        for j = 1:(partitions(2,i)/2)
            int = int + (DataSplited(2,j*partitions(3,i)) ...
                            + 4*DataSplited(2,j*partitions(3,i)+1) ...
                                + DataSplited(2,j*partitions(3,i)+2))*partitions(1,i)/3;
        end
        integrations(1,i) = int;
    elseif mod(partitions(2,i),3) == 0
        %apply simpson's 3/8 rule
        int = 0;
        for j = 1:(partitions(2,i)/3)
            int = int + (DataSplited(2,j*partitions(3,i)) ...
                            + 3*DataSplited(2,j*partitions(3,i)+1) ...
                                + 3*DataSplited(2,j*partitions(3,i)+2) ...
                                    + DataSplited(2,j*partitions(3,i)+3))*partitions(1,i)*3/8;
        end
        integrations(1,i) = int;
    end
end
clear i;clear j;clear int; clear m;clear n;clear NOP; % clearing temp variables

Volume = sum(integrations);
fprintf('The estimated Size of the dam is %d m^3 \n',Volume);

plot(Data_(1,:),Data_(2,:));
grid("on");
