%% Pvector
%{
Vector of potentially calibrated parameters
%}

classdef pvector
   properties (Constant)
      % Transformed guesses lie in this range
      guessMin = 1;
      guessMax = 2;
   end
   properties
      np = 0;        % no of entries
      nameV          % parameter names
      valueV         % array of pstruct
      doCalV         % permitted values of doCal
   end
   
   methods
      % Constructor
      function pv = pvector(nMax, doCalV)
         pv.np = 0;
         pv.doCalV = doCalV;
         pv.nameV = cell([nMax,1]);
         pv.valueV = cell([nMax,1]);
      end
      
      
      % Retrieve by name
      function ps = retrieve(obj, nameStr)
         % Does this param exist?
         idx1 = find(strcmp(obj.nameV, nameStr));
         if ~isempty(idx1)
            ps = obj.valueV{idx1};
         else
            ps = [];
         end
      end
      
      
      % Add new parameter
      function obj = add(obj, ps)
         % Does this param exist?
         idx1 = find(strcmp(obj.nameV, ps.name));
         if ~isempty(idx1)
            error([ps.name, ' already exists']);
         else
            % Add new parameter
            obj.np = obj.np + 1;
            obj.nameV{obj.np} = ps.name;
            obj.valueV{obj.np} = ps;
         end
      end
      
      
      % Add new param or change existing param
      function obj = change(obj, nameStr, symbolStr, descrStr, valueV, lbV, ubV, doCal)
         % Does this param exist?
         idx1 = find(strcmp(obj.nameV, nameStr));
         if isempty(idx1)
            % Add new parameter
            obj.np = obj.np + 1;
            obj.nameV{obj.np} = nameStr;
            obj.valueV{obj.np} = pstruct(nameStr, symbolStr, descrStr, valueV, lbV, ubV, doCal);
         else
            % Update existing parameter
            ps = obj.valueV{idx1};
            obj.valueV{idx1} = ps.update(valueV, lbV, ubV, doCal);
         end
      end
      
      
      % Change calibration status
      function obj = calibrate(obj, nameStr, doCal)
         % Does this param exist?
         idx1 = find(strcmp(obj.nameV, nameStr));
         if isempty(idx1)
            error('%s does not exist', nameStr);
         end
         obj = obj.change(nameStr, [], [], [], [], [], doCal);
      end
      
      
      % ***  Add all parameters that are not calibrated (or missing) to a struct
      %{
         Also impose bounds when calibrated (doCal >= 1)
      
         IN: 
            p: pvector
            paramS: struct to which fields are to be added
            doCalV: only fields with doCal NOT in doCalV are touched
         OUT:
            paramS with added / updated fields
      %}
      function paramS = struct_update(p, paramS, doCalV)
         % Loop over parameters
         for i1 = 1 : p.np
            % Param struct
            ps = p.valueV{i1};
            pName = p.nameV{i1};
            % Overwrite fields that are not calibrated or missing
            if ~ismember(ps.doCal, doCalV)  ||  (~isfield(paramS, pName))
               % Use exogenous default values
               paramS.(pName) = ps.valueV;
            end
            if ps.doCal >= 1
               % Impose bounds
               paramS.(pName) = max(ps.lbV, min(ps.ubV, paramS.(pName)));
            end
         end
      end
      
      
      % ***  Copy parameters for which doCal in doCalV from one struct into another
      function paramS = param_copy(p, paramToS, paramFromS, doCalV)
         paramS = paramToS;
         % Loop over parameters
         for i1 = 1 : p.np
            % Param struct
            ps = p.valueV{i1};
            % Overwrite fields that are not calibrated or missing
            if ismember(ps.doCal, doCalV) 
               % Use exogenous default values
               pName = p.nameV{i1};
               paramS.(pName) = paramFromS.(pName);
            end
         end
      end
      
      
      % ******  Make transformed parameter vector (for optimization routines
      % Make it out of paramS structure that contains all calibrated params
      %{
      IN
         doCalV
            only params with doCal in doCalV are put into guessV
      %}
      function guessV = guess_make(p, paramS, doCalV)
         % Get all the calibrated params into a single vector
         guessV = nan([100,1]);
         lbV = nan([100,1]);
         ubV = nan([100,1]);
         % Last entry in guessV that is filled
         idx1 = 0;
         for i1 = 1 : p.np
            ps = p.valueV{i1};
            if any(ps.doCal == doCalV)
               idxV = idx1 + (1 : length(ps.valueV));
               % Take the value out of the paramS struct
               guessV(idxV) = paramS.(ps.name);
               lbV(idxV) = ps.lbV;
               ubV(idxV) = ps.ubV;
               idx1 = idxV(end);
            end
         end
         
         % Drop unused elements
         if length(guessV) > idx1
            idxV = (idx1 + 1) : length(guessV);
            guessV(idxV) = [];
            lbV(idxV) = [];
            ubV(idxV) = [];
         end
         
         % Make sure all guesses are in range
         guessV = min(ubV, max(lbV, guessV));

         % Transform
         guessV = p.guessMin + (guessV - lbV) .* (p.guessMax - p.guessMin) ./ (ubV - lbV);
      end
      
      
      % *****  Make guesses into parameters
      % Inverts guess_make
      %{
      IN
         doCalV
            only guesses with doCal in doCalV are used
      %}
      function paramS = guess_extract(p, guessV, paramS, doCalV)
         % Last entry in guessV that is used
         idx1 = 0;
         % Loop over calibrated guesses
         for i1 = 1 : p.np
            ps = p.valueV{i1};
            if any(ps.doCal == doCalV)
               % Position in guess vector
               idxV = idx1 + (1 : length(ps.valueV));
               paramS.(ps.name) = ps.lbV  +  (guessV(idxV) - p.guessMin) .* (ps.ubV - ps.lbV) ./ ...
                  (p.guessMax - p.guessMin);
               idx1 = idxV(end);
            end
         end
      end
      
      
      % ******  Show params that are close to bounds
      %{
      Only for params that are calibrated (ps.Cal == doCalV)
      IN:
         fp
            file pointer for output text file
      %}
      function show_close_to_bounds(p, paramS, doCalV, fp)
         % Tolerance
         dTol = 1e-2;
         fprintf(fp, '\nParameters that are close to bounds\n');
         for i1 = 1 : p.np
            ps = p.valueV{i1};
            if any(ps.doCal == doCalV)
               value2V = paramS.(ps.name);
               % Differences should be positive
               diffUbV = (ps.ubV(:) - value2V(:)) ./ max(0.1, abs(value2V(:)));
               diffLbV = (value2V(:) - ps.lbV(:)) ./ max(0.1, abs(value2V(:)));
               idxV = find((abs(diffUbV) < dTol)  |  (abs(diffLbV) < dTol));
               if ~isempty(idxV)
                  fprintf(fp, '  %s:  ',  ps.name);
                  for i2 = 1 : length(value2V)
                     fprintf(fp, '  [%.3f %.3f %.3f]',  ps.lbV(i2), value2V(i2), ps.ubV(i2));
                     if rem(i2, 5) == 0
                        fprintf(fp, '\n');
                     end
                  end
                  fprintf(fp, '\n');
               end
            end
         end
      end
   end
end

