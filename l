class Solution:
    def lenOfVDiagonal(self, grid):
        n, m = len(grid), len(grid[0])
        # directions: 0=↘ (1,1), 1=↖ (-1,-1), 2=↙ (1,-1), 3=↗ (-1,1)
        dirs = [(1,1), (-1,-1), (1,-1), (-1,1)]
        # clockwise mapping: old_dir -> new_dir after clockwise 90°
        clockwise = {0:2, 2:1, 1:3, 3:0}
        inv_clockwise = {v:k for k,v in clockwise.items()}

        # straight[i][j][d] = length of alternating segment ending at (i,j) moving in direction d (no turn)
        # turn[i][j][d] = length ending at (i,j) moving in direction d, having already made one clockwise turn
        straight = [[[0]*4 for _ in range(m)] for _ in range(n)]
        turn = [[[0]*4 for _ in range(m)] for _ in range(n)]
        ans = 0
        g = grid  # local alias

        # Helper for scan ranges depending on the sign of dx/dy
        def range_for(step, limit):
            return range(0, limit) if step == 1 else range(limit-1, -1, -1)

        # Phase 1: compute straight lengths for each direction with proper scan order
        for d, (dx, dy) in enumerate(dirs):
            ir = range_for(dx, n)
            jr = range_for(dy, m)
            for i in ir:
                row_i = g[i]
                for j in jr:
                    val = row_i[j]
                    if val == 1:
                        # a 1 can start a straight sequence of length 1 in any direction
                        if straight[i][j][d] < 1:
                            straight[i][j][d] = 1
                            if ans < 1: ans = 1

                    pi, pj = i - dx, j - dy
                    if 0 <= pi < n and 0 <= pj < m:
                        L = straight[pi][pj][d]
                        if L > 0:
                            expected = 2 if (L % 2 == 1) else 0
                            if val == expected:
                                newL = L + 1
                                if newL > straight[i][j][d]:
                                    straight[i][j][d] = newL
                                    if newL > ans: ans = newL

        # Phase 2: compute turned sequences (one clockwise 90° turn) for each direction
        for d, (dx, dy) in enumerate(dirs):
            old_d = inv_clockwise[d]  # straight direction that can turn clockwise into d
            ir = range_for(dx, n)
            jr = range_for(dy, m)
            for i in ir:
                row_i = g[i]
                for j in jr:
                    val = row_i[j]
                    pi, pj = i - dx, j - dy
                    if 0 <= pi < n and 0 <= pj < m:
                        # pivot: turn from a straight segment that ended at prev cell in old_d
                        Ls = straight[pi][pj][old_d]
                        if Ls > 0:
                            expected = 2 if (Ls % 2 == 1) else 0
                            if val == expected:
                                newL = Ls + 1
                                if newL > turn[i][j][d]:
                                    turn[i][j][d] = newL
                                    if newL > ans: ans = newL

                        # extend an already-turned segment along the same direction d
                        Lt = turn[pi][pj][d]
                        if Lt > 0:
                            expected2 = 2 if (Lt % 2 == 1) else 0
                            if val == expected2:
                                newL2 = Lt + 1
                                if newL2 > turn[i][j][d]:
                                    turn[i][j][d] = newL2
                                    if newL2 > ans: ans = newL2

        return ans
