NO_OF_USERS = 100;
BASE_STATION_1 = [5000 0];
BASE_STATION_2 = [0 10000];
BASE_STATION_3 = [10000 10000];
BASE_STATION_CAPACITY = 20;
ACTIVE_USERS = 0.25; 

length = 10000;
width = 10000; 

users_x = zeros(1,NO_OF_USERS); 
users_y = zeros(1,NO_OF_USERS);

MIN = -70; 
MAX = -30; 
MINIMUM_SIGNAL_STRENGTH = -110;

SAMPLES = 10;
STEP_SIZE = 0.05;

signal_strengths = MIN:STEP_SIZE:MAX; 
user_count = zeros(SAMPLES,size(signal_strengths,2));

for i = 1:100
    users_x(i) = randi(length,1);
    users_y(i) = randi(width,1);
end

for i = 1:SAMPLES
    [users_x,users_y] = Walk(users_x,users_y);
    fprintf('Step number %d\n',i);
    active = Find_Active_Users(NO_OF_USERS,ACTIVE_USERS); 
    c = 1;
    for s = MIN:STEP_SIZE:MAX
        r = Radius_Calculator(s,MINIMUM_SIGNAL_STRENGTH); 
        [b1,b2,b3] = Assign_Users(active,BASE_STATION_1,BASE_STATION_2,BASE_STATION_3,users_x,users_y,r,s,BASE_STATION_CAPACITY);
        if mod(s,10) == 0
            fprintf('strength = %d, radius = %.5f\n',s,r);
            fprintf('B1 users = %d, B2 users = %d, B3 users = %d\n',b1,b2,b3);
            fprintf('Total users = %d\n\n',b1+b2+b3);
        end
        user_count(i,c) = b1+b2+b3;
        c = c + 1;
    end
end

[M,i] = max(mean(user_count,1)); 
fprintf('Max users %d at %.2f dBm\n',floor(M),(i*STEP_SIZE)+MIN);

Graph(signal_strengths,mean(user_count,1));


function [b1_users,b2_users,b3_users] = Assign_Users(active,b1,b2,b3,users_x,users_y,r,s,capacity)
    b1_users = 0;
    b2_users = 0;
    b3_users = 0;
    for i = 1:length(active)
        
        distance_to_base_stations_1 = Find_distance(users_x(active(i)),users_y(active(i)),b1(1),b1(2));
        distance_to_base_stations_2 = Find_distance(users_x(active(i)),users_y(active(i)),b2(1),b2(2));
        distance_to_base_stations_3 = Find_distance(users_x(active(i)),users_y(active(i)),b3(1),b3(2));

       
        if distance_to_base_stations_1 <= r && distance_to_base_stations_2 <= r && distance_to_base_stations_3 <= r
            
            path_loss_from_b1 = Calculate_Path_Loss(distance_to_base_stations_1);
            path_loss_from_b2 = Calculate_Path_Loss(distance_to_base_stations_2);
            path_loss_from_b3 = Calculate_Path_Loss(distance_to_base_stations_3);
           
            SINR_b1 = Calculate_SINR(1,(s-path_loss_from_b1),(s-path_loss_from_b2),(s-path_loss_from_b3));
            SINR_b2 = Calculate_SINR(1,(s-path_loss_from_b2),(s-path_loss_from_b1),(s-path_loss_from_b3));
            SINR_b3 = Calculate_SINR(1,(s-path_loss_from_b3),(s-path_loss_from_b1),(s-path_loss_from_b2));
          
            if SINR_b1 > 1 &&  SINR_b2 > 1 && SINR_b3 > 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                elseif b2_users < capacity
                    b2_users = b2_users + 1;    
                elseif b3_users < capacity
                    b3_users = b3_users + 1; 
                end
            elseif SINR_b1 > 1 &&  SINR_b2 > 1 && SINR_b3 < 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                elseif b2_users < capacity
                    b2_users = b2_users + 1;     
                end
            elseif SINR_b1 > 1 &&  SINR_b2 < 1 && SINR_b3 > 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                elseif b3_users < capacity
                    b3_users = b3_users + 1; 
                end
            elseif SINR_b1 < 1 &&  SINR_b2 > 1 && SINR_b3 > 1
                if b2_users < capacity
                    b2_users = b2_users + 1;
                elseif b3_users < capacity
                    b3_users = b3_users + 1; 
                end
            elseif SINR_b1 > 1 &&  SINR_b2 < 1 && SINR_b3 < 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                end
            elseif SINR_b1 < 1 &&  SINR_b2 > 1 && SINR_b3 < 1
                if b2_users < capacity
                    b2_users = b2_users + 1;
                end
            elseif SINR_b1 < 1 &&  SINR_b2 < 1 && SINR_b3 > 1
                if b3_users < capacity
                    b3_users = b3_users + 1;
                end
            end
                        
        elseif distance_to_base_stations_1 <= r && distance_to_base_stations_2 <= r && distance_to_base_stations_3 > r
            path_loss_from_b1 = Calculate_Path_Loss(distance_to_base_stations_1);
            path_loss_from_b2 = Calculate_Path_Loss(distance_to_base_stations_2);
            SINR_b1 = Calculate_SINR(0,(s-path_loss_from_b1),(s-path_loss_from_b2));
            SINR_b2 = Calculate_SINR(0,(s-path_loss_from_b2),(s-path_loss_from_b1));
            
            if SINR_b1 > 1 &&  SINR_b2 > 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                elseif b2_users < capacity
                    b2_users = b2_users + 1;    
                end
            elseif SINR_b1 > 1 &&  SINR_b2 < 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                end
            elseif SINR_b1 < 1 &&  SINR_b2 > 1
                if b2_users < capacity
                    b2_users = b2_users + 1;
                end
            end
                       
        elseif distance_to_base_stations_1 <= r && distance_to_base_stations_2 > r && distance_to_base_stations_3 <= r
            path_loss_from_b1 = Calculate_Path_Loss(distance_to_base_stations_1);
            path_loss_from_b3 = Calculate_Path_Loss(distance_to_base_stations_3);
            SINR_b1 = Calculate_SINR(0,(s-path_loss_from_b1),(s-path_loss_from_b3));
            SINR_b3 = Calculate_SINR(0,(s-path_loss_from_b3),(s-path_loss_from_b1));
            
            if SINR_b1 > 1 &&  SINR_b3 > 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                elseif b3_users < capacity
                    b3_users = b3_users + 1;    
                end
            elseif SINR_b1 > 1 &&  SINR_b3 < 1
                if b1_users < capacity
                    b1_users = b1_users + 1;
                end
            elseif SINR_b1 < 1 &&  SINR_b3 > 1
                if b3_users < capacity
                    b3_users = b3_users + 1;
                end
            end
                       
        elseif distance_to_base_stations_1 > r && distance_to_base_stations_2 <= r && distance_to_base_stations_3 <= r
            path_loss_from_b2 = Calculate_Path_Loss(distance_to_base_stations_2);
            path_loss_from_b3 = Calculate_Path_Loss(distance_to_base_stations_3);
            SINR_b2 = Calculate_SINR(0,(s-path_loss_from_b2),(s-path_loss_from_b3));
            SINR_b3 = Calculate_SINR(0,(s-path_loss_from_b3),(s-path_loss_from_b2));
            
            if SINR_b2 > 2 &&  SINR_b3 > 1
                if b2_users < capacity
                    b2_users = b2_users + 1;
                elseif b3_users < capacity
                    b3_users = b3_users + 1;    
                end
            elseif SINR_b2 > 1 &&  SINR_b3 < 1
                if b2_users < capacity
                    b2_users = b2_users + 1;
                end
            elseif SINR_b2 < 1 &&  SINR_b3 > 1
                if b3_users < capacity
                    b3_users = b3_users + 1;
                end
            end
                      
        elseif distance_to_base_stations_1 <= r && distance_to_base_stations_2 > r && distance_to_base_stations_3 > r
            if b1_users < capacity
                b1_users = b1_users + 1;
            end
        elseif distance_to_base_stations_1 > r && distance_to_base_stations_2 <= r && distance_to_base_stations_3 > r
            if b2_users < capacity
                b2_users = b2_users + 1;
            end
        elseif distance_to_base_stations_1 > r && distance_to_base_stations_2 > r && distance_to_base_stations_3 <= r
            if b3_users < capacity
                b3_users = b3_users + 1;
            end
        end
    end    
end

function v = Calculate_SINR(i,p,i1,i2)
    if i == 1
        v = p/(i1+i2);
    else
        v = p/i1;
    end
end

function d = Find_distance(x1,y1,x2,y2)
    d = sqrt((x2-x1)^2+(y2-y1)^2);
end

function i = Find_Active_Users(len,active)
    num_elements = round(active*len);
    indices = randperm(len);
    i = sort(indices(1:num_elements));
end

function l = Calculate_Path_Loss(d)
    n = 2;
    c = 50;
    l = c + 10*n*log10(d);
end

function r = Radius_Calculator(max,min)
    n = 2;
    c = 50;
    r = (10 ^ (((max-min)-c)/(10*n)))*1000;
end

function [x,y] = Walk(x,y)
    for i=1:100
        [x(i),y(i)] = Walk_one_step(x(i),y(i));
    end
end

function [x,y] = Walk_one_step(x,y)
    length = 10000;
    width = 10000;
    theta = 2 * pi * rand();
    speed = randi(10,1)-1; 
    
    dx = round(speed * cos(theta)); 
    dy = round(speed * sin(theta));
    
    temp_x = x + dx; 
    temp_y = y + dy; 
    
    if temp_x > 0 && temp_x <= length
        x = temp_x;
    end
    if temp_y > 0 && temp_y <= width
        y = temp_y;
    end
end

function Graph(s,u)
    plot(s,u,'g');
    xlabel('Base Station signel strength(dBm)');
    ylabel('Total user count received services');
    title('Variation Of Users Getting Services');
end