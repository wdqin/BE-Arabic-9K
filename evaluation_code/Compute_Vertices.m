function Vertices = Compute_Vertices(BB)
Spaces = isspace(BB);
Pointer = 1; Vertices = []; h = 1;
for p = 1: length(BB)
    if strcmp (BB(p), ',')
        Vertices = [Vertices; 0 0];
        Vertices(h,1) = str2double(BB(Pointer:p-1));
        Pointer = p+1;
    elseif (Spaces(p) == 1)
        Vertices(h,2) = str2double(BB(Pointer:p-1));
        Pointer = p+1;
        h = h + 1;
    elseif (p == length(BB))
        Vertices(h,2) = str2double(BB(Pointer:p));
    end
end
Vertices = [Vertices;Vertices(1,1:2)];