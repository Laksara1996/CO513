clc;
tic;
QUEUE_SIZE = 100;
OUT_RATE = 50;

iterations = 10;

default_class_queue = [];
DSCP_22_class_queue = [];
DSCP_46_class_queue = [];

default_drop_class = zeros(1,iterations);
DSCP_22_drop_class = zeros(1,iterations);
DSCP_46_drop_class = zeros(1,iterations);

number_of_inputs = zeros(1,iterations);

for i = 1:iterations
    Input_Rate = 100*i;
    number_of_inputs(i) = Input_Rate;
    fprintf('Iteration = %d , Input_Rate = %d\n',i,Input_Rate);
    [b,c,d] = array_generator(Input_Rate);
    
    disp('Queue sizes after enqueuing');
    [default_class_queue,DSCP_22_class_queue,DSCP_46_class_queue,d1,d2,d3] = enqueue(default_class_queue,DSCP_22_class_queue,DSCP_46_class_queue,b,c,d,QUEUE_SIZE);
    fprintf('%d %d %d\n',length(default_class_queue),length(DSCP_22_class_queue),length(DSCP_46_class_queue));
    disp('Drop packets');
    fprintf('%d %d %d\n',d1,d2,d3);
    
    default_drop_class(i) = d1;
    DSCP_22_drop_class(i) = d2;
    DSCP_46_drop_class(i) = d3;
    
    disp('Queue sizes after dequeuing');
    [default_class_queue,DSCP_22_class_queue,DSCP_46_class_queue] = dequeue(default_class_queue,DSCP_22_class_queue,DSCP_46_class_queue,OUT_RATE);
    fprintf('%d %d %d\n\n',length(default_class_queue),length(DSCP_22_class_queue),length(DSCP_46_class_queue));
end

plotting(number_of_inputs,default_drop_class,DSCP_22_drop_class,DSCP_46_drop_class);

function [b,c,d] = dequeue(b,c,d,r)
   l1 = 1; 
   l2 = 1; 
   l3 = 1;
   if ~isempty(b) && ~isempty(c) && ~isempty(d)
       l1 = round(0.6*r);
       l2 = round(0.3*r);
       l3 = r-(l1+l2);
       if length(b) > l3
           b(1:l3) = [];
       else
           b = [];
       end
       if length(c) > l2
           c(1:l2) = [];
       else
           c = [];
       end
       if length(d) > l1
           d(1:l1) = [];
       else
           d = [];
       end
   elseif  ~isempty(b) && ~isempty(c)
       l2 = round(0.75*r);
       l3 = r-l2;
       if length(b) > l3
           b(1:l3) = [];
       else
           b = [];
       end
       if length(c) > l2
           c(1:l2) = [];
       else
           c = [];
       end
   elseif  ~isempty(b) && ~isempty(d)
       l1 = round(0.8*r);
       l3 = r-l1;
       if length(b) > l3
           b(1:l3) = [];
       else
           b = [];
       end
       if length(d) > l1
           d(1:l1) = [];
       else
           d = [];
       end
   elseif  ~isempty(c) && ~isempty(d) 
       l1 = round(0.667*r);
       l2 = r-l1;
       if length(c) > l2
           c(1:l2) = [];
       else
           c = [];
       end
       if length(d) > l1
           d(1:l1) = [];
       else
           d = [];
       end
   elseif isempty(b) && isempty(c)
       if length(d) > l1
           d(1:l1) = [];
       else
           d = [];
       end
   elseif isempty(b) && isempty(d)
       if length(c) > l2
           c(1:l2) = [];
       else
           c = [];
       end
   elseif isempty(c) && isempty(d)
       if length(b) > l3
           b(1:l3) = [];
       else
           b = [];
       end
   end
end

function [q1,q2,q3,d1,d2,d3] = enqueue(q1,q2,q3,b,c,d,size)
    d1 = 0;
    d2 = 0;
    d3 = 0;
    if length(q1)+length(b) > size
        d1 = length(b) - (size-length(q1));
        q1 = [q1 b(1:size-length(q1))];
    else
        q1 = [q1 b];
    end
    
    if length(q2)+length(c) > size
        d2 = length(c) - (size-length(q2));
        q2 = [q2 c(1:size-length(q2))];
    else
        q2 = [q2 c];
    end
    
    if length(q3)+length(d) > size
        d3 = length(d) - (size-length(q3));
        q3 = [q3 d(1:size-length(q3))];
    else
        q3 = [q3 d];
    end
end

function [b,c,d] = array_generator(r)
   a = zeros(1,r);
   for i = 1:r
       a(1,i) = toc;
   end
  
   number_of_elements = round(0.5*length(a));
   number_of_elements_2 = round(0.25*length(a));

   indices = randperm(length(a));
   indices1 = indices(1:number_of_elements);
   indices2 = indices(length(indices1)+1:length(indices1)+number_of_elements_2);
   indices3 = indices(length(indices1)+length(indices2)+1:end);

   b = sort(a(indices1));
   c = sort(a(indices2));
   d = sort(a(indices3));
end

function plotting(number_of_inputs,d0,d22,d46)
    plot(number_of_inputs,d0,'g');
    hold on
    plot(number_of_inputs,d22,'b');
    hold on
    plot(number_of_inputs,d46,'r');
    hold off
    xlabel('Input rates (pckts/sec)')
    ylabel('No of dropped pckts')
    title('Drop Probability')
    legend({'default forwarding','dscp22','dscp46'},'Location','northwest')
end