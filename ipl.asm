CYLS EQU 10;定义柱面个数为10个
ORG 0x7c00 ;指定程序装载的位置
;下面用于描述FAT12个格式的软盘
JMP entry
DB 0x90
DB "CHRRYIPL" ;启动区的名称可以是任意的字符串，但长度必须是8字节
DW 512; 每一个扇区的大小，必须是512字节
DB 1 ;簇的大小（必须为1个扇区)
DW 1 ;FAT的起始位置（一般从第一个扇区开始）
DB 2 ;FAT的个数 必须是2
DW 224;根目录的大小 一般是224项
DW 2880; 该磁盘的大小 必须是2880扇区
DB 0xf0;磁盘的种类 必须是0xf0
DW 9;FAT的长度 必须是9扇区
DW 18;1个磁道(track) 有几个扇区 必须是18
DW 2; 磁头个数 必须是2
DD 0; 不使用分区，必须是0
DD 2880; 重写一次磁盘大小
DB 0,0,0x29 ;扩展引导标记 固定0x29
DD 0xffffffff ;卷列序号
DB "CHERRY-OS  " ;磁盘的名称（11个字节）
DB "FAT12   " ;磁盘的格式名称（8字节）
TIMES 18 DB 0; 先空出18字节 这里与原文写法不同
;程序核心
entry:
    MOV AX,0  ;初始化寄存器
    MOV SS,AX
    MOV SP,0x7c00
    MOV DS,AX
;读盘
    MOV AX,0x0820
    MOV ES,AX
    MOV CH,0 ;柱面0
    MOV DH,0 ;磁头0
    MOV CL,2 ;扇区2
readloop:
    MOV SI,0 ; 记录失败次数的寄存器
retry:
    MOV AH,0x02 ;AH=0x02 表示读磁盘
    MOV AL,1 ;一个扇区
    MOV BX,0 ;
    MOV DL,0x00 ;A驱动器
    INT 0x13; 调用磁盘BIOS
    JNC next ;没出错的时候跳转到next
    ADD SI,1 ;SI+1
    CMP SI,5 ;比较SI与5
    JAE error; 当SI>=5时 跳转到error
    MOV AH,0x00
    MOV DL,0x00 ;A驱动器
    INT 0x13 ;重置驱动器
    JMP retry
next:
    MOV AX,ES ;把内存地址后移0x200
    ADD AX,0x0020
    MOV ES,AX ;因为没有ADD ES,0x0020 所以只能这样
    ADD CL,1 ;往CL加1
    CMP CL,18 ; 比较CL与18 
    JBE readloop ; 如果CL<=18 跳转到readloop
    MOV CL,1
    ADD DH,1
    CMP DH,2
    JB readloop ;如果DH<2 则跳转到readloop
    MOV DH,0
    ADD CH,1
    CMP CH,CYLS
    JB readloop ;如果CH<CHLS 则跳转到readloop
    
    MOV [0x0ff0],CH
    JMP 0xc200
    
error: 
    MOV SI,msg 
putloop:
    MOV AL,[SI]
    ADD SI,1
    CMP AL,0
    JE fin
    MOV AH,0x0e ;显示一个文字
    MOV BX,15 ;指定字符的颜色
    INT 0x10 ;调用显卡BIOS
    JMP putloop
fin:
    HLT     ;CPU停止,等待指令
    JMP fin ;无限循环
msg:
    DB 0x0a , 0x0a ;换行两次
    DB "load error"
    DB 0x0a
    DB 0
    
    TIMES 0x1fe-($-$$) DB 0 ;填写0x00,直到0x001fe
    
    DB 0x55, 0xaa
    
; 以下是磁盘其他内容
    DB    0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB    4600
    DB    0xf0, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00
    RESB    1469432
