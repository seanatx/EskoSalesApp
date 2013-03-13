	function createGrid( design, data )

	-- shortcut for creating text - x position calculated outside
	function genTxt(txt, yp)
		return display.newText( txt, 0, yp, native.systemFont, 13 )
	end

	local bg
	local grid = display.newGroup()
	local columns = {}
	local xp = 0
	local yp = 0

	for c, wid in ipairs( design.cols ) do
		-- print("formatting", s, set)
		-- 1's and 2's below are padding options. could be passed in via design var
		bg = display.newRect( xp + 2, yp + 2, wid - 4, design.header.height - 4) 
		bg:setFillColor( design.header.bg.r, design.header.bg.g, design.header.bg.b, design.header.bg.a )
		bg:setStrokeColor( design.header.border.r, design.header.border.g, design.header.border.b, design.header.border.a )
		bg.strokeWidth = 2
		grid:insert( bg, false )

		txt = genTxt( data[1][c], design.header.height / 2 + design.toprowfontfix  )
		if c == 1 then
			txt.x = xp + txt.width / 2 + design.leftcolfontfix + design.headerfontfix
		else 
			txt.x = xp + wid / 2 + design.headerfontfix
		end
		grid:insert( txt, false )

		-- create a reference table of calculated column positions and widths
		columns[ c ] = { xp, wid }

		xp = xp + wid
	end

	yp = yp + design.header.height
	-- start from row 2 since 1st row is headers
	for r = 2, #data do
		row = data[r]
		--print("Row", r, row, row[1])
		for c,col in ipairs( row ) do
			--print("Col", c, col, columns[ c ], columns[ c ][ 1 ], columns[ c ][ 2 ] )

			xp,wid = columns[ c ][ 1 ], columns[ c ][ 2 ]

			-- 2's and 4's are padding based on borders. could be passed in via design var
			bg = display.newRect( xp + 2, yp + 2, wid - 4, design.row.height - 4)
			bg:setFillColor( design.row.bg.r, design.row.bg.g, design.row.bg.b, design.row.bg.a )
			bg:setStrokeColor( design.row.border.r, design.row.border.g, design.row.border.b, design.row.border.a )
			bg.strokeWidth = 2
			grid:insert( bg, false )

			txt = genTxt(col, yp)
			if c == 1 then -- do left most column
				txt.x = xp + txt.width / 2 + design.leftcolfontfix + design.cellfontfix
			else 
				txt.x = xp + wid / 2 + design.cellfontfix
			end
			txt.y = txt.y + design.cellfontfixY
			grid:insert( txt, false )

		end

		yp = yp + design.row.height
	end

	return grid
end







-- below are the settings for the grid

design = {
	-- column widths; 260
	cols = { 170, 20, 60, 20 },
	-- vertical alignment for header
	toprowfontfix = -10, 
	-- left most column is left aligned, so padding from left side
	leftcolfontfix = 6, 
	-- in case your chosen font needs some alignment nudging
	headerfontfix = 1, cellfontfix = 3,
	-- for  table text height adjustment
	cellfontfixY = 4,
	-- colours
	header = {
		bg = { r = 169, g = 196, b = 147, a = 200 },
		border = { r = 148, g = 173, b = 130, a = 200},
		height = 35
	},
	row = {
		bg = { r = 169, g = 196, b = 147, a = 160 },
		border = { r = 150, g = 100, b = 150, a = 150 },
		height = 25
	}
}

data = {
	{ "Product","Q","Price.","D"}, -- header row
	{ "Kongsberg Model XN24",1,74400,1 },
	{ "XN24 Base package",1,6052,0 },
	{ "XN24 Designer Style Kit",1,4111,1},
	{ "XN Series Flex Head",1,5770,1},
	{ "Deluxe Corrugated Kit",1,5870,1},
	{ "Ball Point Pens Kit",1,1120,1},
	{ "XN24 Ship, Install",1,16115,0}

}

-- pass them in and voila.
--local t = createGrid( design, data )
--t.x, t.y = 30, 150