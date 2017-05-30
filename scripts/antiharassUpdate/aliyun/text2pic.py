#coding=utf-8
import Image
import ImageDraw
import ImageFont

def changetext(text):
    ret = ''
    size = len(text)
    i = 0
    while i < size:
        if i < size-1 and text[i] == '<' and text[i+1] == 'b':
            i += 6
            ret += '\n'
            continue
        ret += text[i]
        i += 1
    #print ret
    return ret
    
def text2pic(text, filename, ttf_path):
    text = changetext(text)
    imgBg = '#FFFF00'
    textColor = "#000000"
    ttf = ttf_path
    fontSize = 19
    size = (500, 565)

    texts = [""]
    l = 0
    for character in text:
        c = character
        t = len(c)
        if c == '\n':
            texts += [""]
            l = 0
        elif l + t > 23:
            texts += [c]
            l = t
        else:
            texts[-1] += c
            l += t
    body = [(text, textColor) for text in texts]
    img = Image.new('RGB', size, imgBg)
    draw = ImageDraw.Draw(img)
    font = ImageFont.truetype(ttf, fontSize)
    for num, (text, color) in enumerate(body):
        draw.text((2, fontSize * num), text, font=font, fill=color)

    img.save(filename)

if __name__ == '__main__':
    #text = u'上海触宝汉翔cootek徐汇区钦州北路\n1198号82栋12层'
    #text = u'优惠有效期：截止至2013年07月10日<br />1.该优惠有效期：截止至2013年7月10日；<br />2.凭此券可以享受以下优惠：<br />初次限定套餐  嫁接睫毛120根/98元<br />欢迎来体验来自日本的高品质，高技术的睫毛嫁接服务！<br />商户地址: 汉口路398号华盛大厦1906室<br />商户电话：021-53210586<br />营业时间：10：30-21：00<br /><br />[银座Calla美甲美睫沙龙]嫁接睫毛120根/98元<br />凭此券可以享受以下优惠：<br />初次限定套餐  嫁接睫毛120根/98元<br />欢迎来体验来自日本的高品质，高技术的睫毛嫁接服务！<br /><br />---888citysms888---凭短信至银座Calla美甲美睫沙龙,嫁接睫毛120根/98元,更多优惠详询商家,7/10止'
    text = u'优惠有效期：截止至2013年12月08日<br /><br /><br />【温馨提示】<br />酒水、特价菜除外。<br /><br />【微博微信】<br />QQ群：18476261<br />官方微博：丁丁优惠-广州<br />公众微信：丁丁优惠-广州（gzddcoupon)<br />---888citysms888---凭短信至晶晶烤鱼扎啤城,满100元8.8折(酒水/特价菜除外),萧岗二社10号,15099989208,12月8日止'
    #print type(text)
