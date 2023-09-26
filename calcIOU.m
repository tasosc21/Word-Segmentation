function f=calcIOU(MethodResults,GroundTruth)

% all ground truth [gtxmin gtymin gtxmax gtymax]
xmin=MethodResults(:,1);
ymin=MethodResults(:,2);
xmax=MethodResults(:,3);
ymax=MethodResults(:,4);
gtxmin=GroundTruth(:,1);
gtymin=GroundTruth(:,2);
gtxmax=GroundTruth(:,3);
gtymax=GroundTruth(:,4);

RArea=(xmax-xmin+1).*(ymax-ymin+1);
GTArea=(gtxmax-gtxmin+1).*(gtymax-gtymin+1);

Intersect=rectint([xmin ymin (xmax-xmin+1) (ymax-ymin+1)],...
    [gtxmin gtymin (gtxmax-gtxmin+1) (gtymax-gtymin+1)]);
Union=bsxfun(@plus,RArea,GTArea')-Intersect;

f=Intersect./Union;

