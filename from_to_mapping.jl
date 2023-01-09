### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 9c9cc052-6106-11ed-05dd-1dad847f76cd
begin
	using PlutoUI, Markdown
	using ODBC, DBInterface
	using CSV, DataFrames
end

# ╔═╡ acf1e1b1-c27b-44f6-b8ce-6ae2e892f206
begin
	importdata(file) = UInt8.(file["data"]) |> IOBuffer |> CSV.File |> DataFrame

	getnonmissingarr(arr) = [elm for elm in arr |> unique if typeof(elm) != Missing]

	query2df(conn, q) = DBInterface.execute(conn, q) |> DataFrame

	correct(text) = Markdown.MD(Markdown.Admonition("correct", "✔️ Uhuuul!", [text]))

	danger(text) = Markdown.MD(Markdown.Admonition("danger", "❌ Ooops!", [text]))
end;

# ╔═╡ ab175c22-70d1-467e-af10-4d9351d6e908
PlutoUI.TableOfContents(title="Etapas", indent=true, depth=4, aside=true)

# ╔═╡ 62aa3d13-3c5c-45b6-abb0-04339f9ae01f
html"""
<p align="center">
  <img src="https://cdn-msaudata.pressidium.com/wp-content/uploads/2021/11/Datamine_rgb-1-1024x236.png" width="400"><br>
</p>
"""

# ╔═╡ fdd735bc-ff49-4917-8d41-40b726de9851
md"# 🗺️ Mapeamento dos Itens de Lista"

# ╔═╡ ce462e04-16d5-4624-b665-a7d4c005dd08
md"""
#### Conexão ODBC
"""

# ╔═╡ 98ccaff2-db59-4048-a366-1754cc04b502
md"""
|                    |                                                    |
|:------------------:|:--------------------------------------------------:|
|**Driver** | $(@bind driver Select(["SQL Server" => "Central","ODBC Driver 17 for SQL Server" => "Local"])) |
|**Tipo de conexão** | $(@bind conn_type Select(["Windows Authentication", "Database Authentication"])) |
"""

# ╔═╡ 39df812f-4d58-4676-be61-b315bff1e889
if conn_type == "Windows Authentication"
	md"""
	|                    |                                                    |
	|:------------------:|:--------------------------------------------------:|
	|**Servidor**        | $(@bind server TextField(default="NB-5SHWRP2"))    |
	|**Banco de dados**  | $(@bind db TextField(default="GDMS_Central_ATN")) |
	"""
else
	md"""
	|                    |                                                    |
	|:------------------:|:--------------------------------------------------:|
	|**Servidor**        | $(@bind server TextField(default="NB-5SHWRP2"))    |
	|**Banco de dados**  | $(@bind db TextField(default="GDMS_Vale_Central")) |
	|**Usuário**         | $(@bind user TextField())                          |
	|**Senha**           | $(@bind pwd TextField())                           |
	"""
end

# ╔═╡ a06f0323-01d4-406d-8cbb-31221de4122d
md"**🔄 Conectar** $(@bind makeconn CheckBox())"

# ╔═╡ 3b2ddfe1-5055-490f-9824-66aeedca9374
begin
	if makeconn
		if conn_type == "Windows Authentication"
			if server != "" && db != ""
				conn = ODBC.Connection("Driver=$driver;SERVER=$server;DATABASE=$db")
				correct(md"Conexão com o banco de dados $db realizada com sucesso!")
			else
				danger(md"Preencha todos os parâmetros!")
			end
		else
			if server != "" && db != "" && user != "" && pwd != ""
				conn = ODBC.Connection("Driver=$driver;SERVER=$server;DATABASE=$db;UID=$user;PWD=$pwd")
				correct(md"Conexão com o banco de dados $db realizada com sucesso!")
			else
				danger(md"Preencha todos os parâmetros!")
			end
		end
	end
end

# ╔═╡ c244c95a-7c9a-40bf-a549-d4e5c23e0725
if makeconn
	md"#### Validação dos Itens de Lista"
end

# ╔═╡ 3d568b95-c996-40a4-aeba-edebf5f53c41
if makeconn
	md"""
	$(@bind itemresetbtn Button("Limpar"))
	"""
end

# ╔═╡ 3f52fe7d-feee-40c2-b0e5-09019e504073
if makeconn
	itemresetbtn
	
	@bind itemfile FilePicker([MIME("text/csv")])
end

# ╔═╡ 43eda323-2aa3-419f-99d6-5834352b35b8
begin
	if makeconn && itemfile != nothing
		itemdf = importdata(itemfile)
		itemfilecols = names(itemdf)
	end
end;

# ╔═╡ d50bde54-3dc3-4b7c-b2c3-c00be341ddbb
if makeconn && itemfile != nothing
	q₁ = "SELECT TABLE_NAME FROM USER_DEFINED_TABLE_NAME WHERE table_type='L'"
	itemrefs = query2df(conn, q₁).TABLE_NAME
end;

# ╔═╡ 8ca88e61-9bfc-4eeb-84eb-e8eaa0f0f119
begin
	if makeconn
		if itemfile != nothing
			item1 = @bind itemfilecol Select(itemfilecols)
			item2 = @bind itemref Select(itemrefs)
		end
	end
end;

# ╔═╡ b2ff8842-df6f-42df-84fc-3a3651e53a5f
if makeconn && itemfile != nothing && itemref != ""
	q₂ = "SELECT * FROM $itemref"
	itemrefdf = query2df(conn, q₂)
	itemrefcols = names(itemrefdf)
end;

# ╔═╡ 80f90780-b1ef-4536-b3a1-812679d4347c
begin
	if makeconn
		if itemfile != nothing
			item3 = @bind itemrefcol Select(itemrefcols)
		end
	end
end;

# ╔═╡ 3d44f1c5-8c6d-4f3b-838b-14fe4f655f11
if makeconn
	if itemfile != nothing
		md"""
		|                                  |        |
		|:--------------------------------:|:------:|
		| **Coluna (arquivo)**             | $item1 |
		| **Lista de referência**          | $item2 |
		| **Coluna (lista de ref.)**       | $item3 |
		"""
	end
end

# ╔═╡ 53c1de0f-db27-46c8-8f01-469e27597721
if makeconn && itemfile != nothing
	md"""
	**▶️ Executar validação** $(@bind itemvalid CheckBox())
	**💾 Salvar itens inconsistentes** $(@bind itemsave CheckBox())
	"""
end

# ╔═╡ c1708a25-571a-4411-ba47-b158242474a8
if makeconn
	if itemfile != nothing
		if itemvalid
			itemfileuniques = getnonmissingarr(itemdf[!,itemfilecol])
			itemrefuniques = itemrefdf[!,itemrefcol]
			itemdiff = [f for f in itemfileuniques if f ∉ itemrefuniques]
			
			if length(itemdiff) == 0
				correct(md"Nenhuma inconsistência detectada!")
			elseif length(itemdiff) == 1
				danger(md"Foi encontrada $(length(itemdiff)) inconsistência.")
			else
				danger(md"Foram encontradas $(length(itemdiff)) inconsistências.")
			end
		end
	end
end

# ╔═╡ b5a45e0c-1c24-44ea-bf35-75ed8f6fa855
if makeconn
	if itemfile != nothing
		if itemvalid
			mapfileuniques = getnonmissingarr(itemdf[!,itemfilecol])
			mapdiff = [f for f in mapfileuniques if f ∉ itemrefuniques]
			if length(mapdiff) != 0
				map1 = @bind mapinconscode Select(mapdiff)
			else
				map1 = @bind mapinconscode Select([""])
			end
			maprefuniques = itemrefdf[!,itemrefcol]
			if length(maprefuniques) != 0
				map2 = @bind mapnewcode Select(maprefuniques)
			else
				map2 = @bind mapnewcode Select([""])
			end
		end
	end
end;

# ╔═╡ 4c1d041a-bc27-4fde-8907-001b4a1de482
if makeconn
	if itemfile != nothing
		if itemsave
			if itemvalid
				itemfinaldf = DataFrame(itens_inconsistentes = itemdiff)
				CSV.write("C:\\$(itemfilecol)_incons.csv", itemfinaldf)
				correct(md"'$(itemfilecol)_incons.csv' salvo com sucesso no disco C!")
			end
		end
	end
end

# ╔═╡ 9f5fed54-7447-4619-8020-65a3fbd7a3a9
if makeconn
	if itemfile != nothing
		if itemvalid
			md"""#### De ➡ Para"""
		end
	end
end

# ╔═╡ ffc3c8dd-0871-4f47-b75c-a0873489708b
if makeconn
	if itemfile != nothing
		if itemvalid
			md"""**➕ Item novo não existe na lista** $(@bind newitemcbx CheckBox())"""
		end
	end
end

# ╔═╡ 50543945-2b4b-469a-91c4-ac80465bb803
if makeconn
	if itemfile != nothing
		if itemvalid
			if length(itemdiff) != 0
				if newitemcbx
					md"""
					|                                  |        |
					|:--------------------------------:|:------:|
					| **Item original (de)**           | $map1  |
					"""
				else
					md"""
					|                                  |        |
					|:--------------------------------:|:------:|
					| **Item original (de)**           | $map1  |
					| **Item novo (para)**             | $map2  |
					"""
				end
			else
				correct(md"Não há necessidade de realizar um mapeamento! Clique no botão 💾 abaixo para salvar os mapeamentos prévios.")
			end
		end
	end
end

# ╔═╡ d936cfea-74d2-40e3-9ea9-a8f0bf075548
if makeconn
	if itemfile != nothing
		if itemvalid
			if newitemcbx
				md"""
					|                      |                                  |
					|:--------------------:|:--------------------------------:|
					| **Item novo (para)** | $(@bind newitemtbx TextField())  |
					"""
			end
		end
	end
end

# ╔═╡ 0db31831-b4db-46d6-b7e6-bdd094647932
if makeconn
	if itemfile != nothing
		if itemvalid
			if length(itemdiff) != 0
				md"""
				**▶️ Executar "de/para"** $(@bind mapreplace CheckBox())
				**💾 Salvar tabela** $(@bind mapsave CheckBox())
				"""
			else
				md"""
				**💾 Salvar tabela** $(@bind mapsave CheckBox())
				"""
			end
		end
	end
end

# ╔═╡ 5cb230a0-bcbe-4e2a-a776-f41fc78879fa
if makeconn
	if itemfile != nothing
		if itemvalid
			if length(itemdiff) != 0
				if mapreplace
					if newitemcbx
						replace!(itemdf[!,itemfilecol], mapinconscode => newitemtbx)
						correct(md"""Item "$mapinconscode" substituído com sucesso!""")
					else
						replace!(itemdf[!,itemfilecol], mapinconscode => mapnewcode)
						correct(md"""Item "$mapinconscode" substituído com sucesso!""")
					end
				end
			end
		end
	end
end

# ╔═╡ 9edfa177-c354-4ef5-8dd2-eb8e2a742188
if makeconn
	if itemfile != nothing
		if itemvalid
			if mapsave
				CSV.write("C:\\mapped_table.csv", itemdf)
				correct(md"`mapped_table.csv` salvo com sucesso no disco C!")
			end
		end
	end
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
DBInterface = "a10d1c49-ce27-4219-8d33-6db1a4562965"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Markdown = "d6f4376e-aef5-505a-96c1-9c027394607a"
ODBC = "be6f12e9-ca4f-5eb2-a339-a4f995cc0291"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
CSV = "~0.10.7"
DBInterface = "~2.5.0"
DataFrames = "~1.4.2"
ODBC = "~1.1.2"
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.8.2"
manifest_format = "2.0"
project_hash = "e00d3d6f261580a957db2a475b76550449df622b"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.1"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings"]
git-tree-sha1 = "c5fd7cd27ac4aed0acf4b73948f0110ff2a854b2"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.7"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "e7ff6cadf743c098e08fca25c91103ee4303c9bb"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.15.6"

[[deps.ChangesOfVariables]]
deps = ["ChainRulesCore", "LinearAlgebra", "Test"]
git-tree-sha1 = "38f7a08f19d8810338d4f5085211c7dfa5d5bdd8"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.4"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "ded953804d019afa9a3f98981d99b33e3db7b6da"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.Compat]]
deps = ["Dates", "LinearAlgebra", "UUIDs"]
git-tree-sha1 = "3ca828fe1b75fa84b021a7860bd039eaea84d2f2"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.3.0"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "0.5.2+0"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DBInterface]]
git-tree-sha1 = "9b0dc525a052b9269ccc5f7f04d5b3639c65bca5"
uuid = "a10d1c49-ce27-4219-8d33-6db1a4562965"
version = "2.5.0"

[[deps.DataAPI]]
git-tree-sha1 = "e08915633fcb3ea83bf9d6126292e5bc5c739922"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.13.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "Future", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrettyTables", "Printf", "REPL", "Random", "Reexport", "SnoopPrecompile", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "5b93f1b47eec9b7194814e40542752418546679f"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.4.2"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "d1fff3a548102f48987a52a2e0d114fa97d730f0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.13"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.DecFP]]
deps = ["DecFP_jll", "Printf", "Random", "SpecialFunctions"]
git-tree-sha1 = "a8269e0a6af8c9d9ae95d15dcfa5628285980cbb"
uuid = "55939f99-70c6-5e9b-8bb0-5071ed7d61fd"
version = "1.3.1"

[[deps.DecFP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e9a8da19f847bbfed4076071f6fef8665a30d9e5"
uuid = "47200ebd-12ce-5be5-abb7-8e082af23329"
version = "2.0.3+1"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "c36550cb29cbe373e95b3f40486b9a4148f89ffd"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.2"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates", "Mmap", "Printf", "Test", "UUIDs"]
git-tree-sha1 = "e27c4ebe80e8699540f2d6c805cc12203b614f12"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.20"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InlineStrings]]
deps = ["Parsers"]
git-tree-sha1 = "b5081bd8a53eeb6a2ef956751343ab44543023fb"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.3.1"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "49510dfcb407e572524ba94aeae2fced1f3feb0f"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.8"

[[deps.InvertedIndices]]
git-tree-sha1 = "bee5f1ef5bf65df56bdd2e40447590b272a5471f"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.1.0"

[[deps.IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "abc9885a7ca2052a736a600f7fa66209f96506e1"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.4.1"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.3"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "7.84.0+0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.10.2+0"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "94d9c52ca447e23eac0c0f074effbcd38830deb5"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.18"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.0+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2022.2.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.ODBC]]
deps = ["DBInterface", "Dates", "DecFP", "Libdl", "Printf", "Random", "Scratch", "Tables", "UUIDs", "Unicode", "iODBC_jll", "unixODBC_jll"]
git-tree-sha1 = "7fe19bed38551e3169edaec8bb8673354d355681"
uuid = "be6f12e9-ca4f-5eb2-a339-a4f995cc0291"
version = "1.1.2"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.20+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "13652491f6856acfd2db29360e1bbcd4565d04f1"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.5+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "cceb0257b662528ecdf0b4b4302eb00e767b38e7"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.8.0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "a6062fe4063cdafe78f4a0a81cfffb89721b30e7"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.2"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "47e5f437cc0e7ef2ce8406ce1e7e24d44915f88d"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.3.0"

[[deps.PrettyTables]]
deps = ["Crayons", "Formatting", "LaTeXStrings", "Markdown", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "98ac42c9127667c2731072464fcfef9b819ce2fa"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.2.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "f94f779c94e58bf9ea243e77a37e16d9de9126bd"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "efd23b378ea5f2db53a55ae53d3133de4e080aa9"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.3.16"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.SpecialFunctions]]
deps = ["ChainRulesCore", "IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "d75bda01f8c31ebb72df80a46c88b25d1c79c56d"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.1.7"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.StringManipulation]]
git-tree-sha1 = "46da2434b41f41ac3594ee9816ce5541c6096123"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.3.0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.0"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "OrderedCollections", "TableTraits", "Test"]
git-tree-sha1 = "c79322d36826aa2f4fd8ecfa96ddb47b174ac78d"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.10.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.TranscodingStreams]]
deps = ["Random", "Test"]
git-tree-sha1 = "8a75929dcd3c38611db2f8d08546decb514fcadf"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.9.9"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "e59ecc5a41b000fa94423a578d29290c7266fc10"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.12+3"

[[deps.iODBC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "785395fb370d696d98da91eddedbdde18d43b0e3"
uuid = "80337aba-e645-5151-a517-44b13a626b79"
version = "3.52.15+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.1.1+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.48.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+0"

[[deps.unixODBC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg"]
git-tree-sha1 = "228f4299344710cf865b3659c51242ecd238c004"
uuid = "1841a5aa-d9e2-579c-8226-32ed2af93ab1"
version = "2.3.9+0"
"""

# ╔═╡ Cell order:
# ╟─9c9cc052-6106-11ed-05dd-1dad847f76cd
# ╟─acf1e1b1-c27b-44f6-b8ce-6ae2e892f206
# ╟─ab175c22-70d1-467e-af10-4d9351d6e908
# ╟─62aa3d13-3c5c-45b6-abb0-04339f9ae01f
# ╟─fdd735bc-ff49-4917-8d41-40b726de9851
# ╟─ce462e04-16d5-4624-b665-a7d4c005dd08
# ╟─98ccaff2-db59-4048-a366-1754cc04b502
# ╟─39df812f-4d58-4676-be61-b315bff1e889
# ╟─43eda323-2aa3-419f-99d6-5834352b35b8
# ╟─a06f0323-01d4-406d-8cbb-31221de4122d
# ╟─d50bde54-3dc3-4b7c-b2c3-c00be341ddbb
# ╟─b2ff8842-df6f-42df-84fc-3a3651e53a5f
# ╟─3b2ddfe1-5055-490f-9824-66aeedca9374
# ╟─80f90780-b1ef-4536-b3a1-812679d4347c
# ╟─8ca88e61-9bfc-4eeb-84eb-e8eaa0f0f119
# ╟─c244c95a-7c9a-40bf-a549-d4e5c23e0725
# ╟─3f52fe7d-feee-40c2-b0e5-09019e504073
# ╟─3d568b95-c996-40a4-aeba-edebf5f53c41
# ╟─3d44f1c5-8c6d-4f3b-838b-14fe4f655f11
# ╟─c1708a25-571a-4411-ba47-b158242474a8
# ╟─b5a45e0c-1c24-44ea-bf35-75ed8f6fa855
# ╟─53c1de0f-db27-46c8-8f01-469e27597721
# ╟─4c1d041a-bc27-4fde-8907-001b4a1de482
# ╟─9f5fed54-7447-4619-8020-65a3fbd7a3a9
# ╟─50543945-2b4b-469a-91c4-ac80465bb803
# ╟─ffc3c8dd-0871-4f47-b75c-a0873489708b
# ╟─d936cfea-74d2-40e3-9ea9-a8f0bf075548
# ╟─5cb230a0-bcbe-4e2a-a776-f41fc78879fa
# ╟─0db31831-b4db-46d6-b7e6-bdd094647932
# ╟─9edfa177-c354-4ef5-8dd2-eb8e2a742188
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
