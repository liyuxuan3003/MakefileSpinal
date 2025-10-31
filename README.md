# MakefileSpinal

MakefileSpinal是一个适用于SpinalHDL项目的Makefile。

MakefileSpinal的核心功能是：编译指定模块为Verilog，运行指定模块的Verilator仿真并用GTKWave查看波形。

MakefileSpinal通过两个简单的Tcl脚本集成了Vivado烧写上板的功能，你可以很轻松的将你的SpinalHDL设计在FPGA上验证，无需创建庞大的Vivado工程！

## 引入方式
MakefileSpinal应当以Git子模块的方式引入Spinal项目中，假设Spinal项目结构如下
```
SpinalSulfurTemplate [Your Repo Root]
|- .git
|- .gitignore
|- .scalafmt.conf
|- README.md
|- SpinalSulfur
    |- makefile-spinal [Add Submodule Here]
        |- makefile-spinal.mk
        |- vivado-bitstream.tcl
        |- vivado-program.tcl
        |- README.md
    |- TopLevel.scala
    |- Config.scala
    |- build.sbt
    |- Makefile
```

那么，该子模块应当位于`SpinalSulfur/makefile-spinal`处，输入以下命令
```
git submodule add --name "MakefileSpinal" -b github git@github.com:liyuxuan3003/MakefileSpinal.git SpinalSulfur/makefile-spinal
```

同时，你应当在你的Makefile中写入以下内容
```
PROJECT:=SpinalSulfur

TOP:=TopLevel

include makefile-spinal/makefile-spinal.mk
```

`${PROJECT}`设定的内容应当和Scala代码中的`package ...`对应，这也应当是Scala代码所在文件夹的名称。

`${TOP}`设定了默认的模块，后续也可以从命令行上灵活指定需要进行编译和仿真的模块。

## 使用方式
MakefileSpinal对于部分操作提供了多个作用相同的命令（例如`make sim`和`make run`），使部分软件工作流中的常用命令可以沿用。

生成模块的Verilog代码（等同于`make`）
```
make verilog
```

生成模块的VHDL代码
```
make vhdl
```

运行模块的仿真（等同于`make run`）
```
make sim
```

打开模块的仿真波形
```
make gtkwave
```

产生`.bit`文件（用于FPGA加载）
```
make bitstream
```

产生`.bin`文件（用于FPGA烧写）
```
make binfile
```

将`.bit`文件加载到FPGA中
```
make load
```

将`.bin`文件烧写到FPGA的Flash中
```
make burn
```

上述命令默认的操作对象是`TOP`指定的模块，若期望操作一个不同的模块，可以通过在命令行上设置`TARGET`的值来实现。例如，若希望编译或仿真一个称为`Test`的模块，对应的命令分别可以是
```
make TARGET=Test
make run TARGET=Test
```

清理`build`目录
```
make clean
```

清理`build`目录和Scala产生的`project`、`target`、`.bloop`
```
make clean-all
```

## 代码约定
MakefileSpinal需要你的代码符合以下形式，以确保相关命令可以正常生效。

MakefileSpinal假定所有的`scala`代码均位于和主项目的Makefile位于同一级目录。

对于一个模块`Test`，你应当创建一个`Test.scala`，其中至少要包含以下四项内容
1. `Test`，继承自`Component`的`case class`，实现模块。
2. `TestSim`，继承自`App`，实现模块的仿真。
3. `TestVerilog`，继承自`App`，实现生成模块的Verilog代码。
4. `TestVhdl`，继承自`App`，实现生成模块的VHDL代码。
```scala
case class Test() extends Component {}

object TestSim extends App {}

object TestVerilog extends App {}

object TestVhdl extends App {}
```

另外，如果你为`Test.scala`创建了一个`Test.gtkw`的GTKWave配置文件（包含打开哪些波形并以何种方式显示该波形等信息），那么`make gtkwave TARGET=Test`时该文件会自动被读取。

