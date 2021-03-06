//
//  开源：https://github.com/cyq1162/Sagit
//  作者：陈裕强 create on 2017/12/12.
//  博客：(昵称：路过秋天） http://www.cnblogs.com/cyq1162/
//  起源：IT恋、IT连 创业App http://www.itlinks.cn
//  Copyright © 2017-2027年. All rights reserved.
//

#import "STUIImageView.h"
#import "STMsgBox.h"
#import <objc/runtime.h>
#import "STSagit.h"
#import "STUIView.h"
#import "STUIViewEvent.h"
#import "STString.h"
#import "STDictionary.h"

@implementation UIImageView(ST)

//static char pickChar='p';
//-(void)setPickBlock:(OnPick)block
//{
//    objc_setAssociatedObject(self, &pickChar, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
//}
-(UIImageView *)corner:(BOOL)yesNo
{
    [self clipsToBounds:yesNo];
    if(yesNo)
    {
        [self layerCornerRadiusToHalf];
    }
    else
    {
        self.layer.cornerRadius=0;
    }
    return self;
}
-(UIImageView *)longPressSave:(BOOL)yesNo
{
    if(yesNo)
    {
        [self addLongPress:@"save" target:self];
    }
    else
    {
        [self removeLongPress];
    }
    return self;
}

-(UIImageView*)save
{
    [Sagit.MsgBox confirm:@"是否保存图片？" title:@"消息提示" click:^BOOL(NSInteger isOK,UIAlertView* view) {
        if(isOK>0)
        {
            [self.image save:^(NSError *err) {
                [Sagit.MsgBox prompt:!err?@"保存成功":@"保存失败:保存照片权限被拒绝，您需要重新设置才能保存！"];
            }];
        }
        return YES;
    }];
    return self;
}

-(NSString *)url
{
    return [self key:@"url" ];
}

-(UIImageView *)url:(NSString *)url
{
    return [self url:url default:nil maxKb:256];
}
//-(UIImageView *)url:(NSString *)url after:(AfterSetImageUrl)block
//{
//    return [self url:url maxKb:256 default:nil after:block];
//}
-(UIImageView *)url:(NSString *)url default:(id)imgOrName
{
    return [self url:url default:imgOrName maxKb:256 ];
}
//-(UIImageView *)url:(NSString *)url maxKb:(NSInteger)compress
//{
//    return [self url:url maxKb:compress default:nil  after:nil];
//}
//-(UIImageView *)url:(NSString *)url maxKb:(NSInteger)compress default:(id)imgOrName
//{
//    return [self url:url maxKb:compress default:nil after:nil];
//}
-(UIImageView *)url:(NSString *)url default:(id)imgOrName maxKb:(NSInteger)compress //after:(AfterSetImageUrl)block
{
    AfterEvent block=self.onAfter;
    if([NSString isNilOrEmpty:url])
    {
        
        if(block){block(@"url",self);block=nil;}
        return self;
    }
    [self key:@"url" value:url];
    if(![url startWith:@"http"])
    {
        [self image:url];
        if(block){block(@"url",self);block=nil;}
        return self;
    }
    NSString *cacheKey=[@"STImgUrl_" append:[@([url hash]) stringValue]];
    NSData * cacheImg=[Sagit.File get:cacheKey];
    //检测有没有缓存
    if(cacheImg)
    {
        [self image:cacheImg];
        if(block){block(@"url",self);block=nil;}
        return self;
    }
    if(imgOrName)
    {
        self.image=[self toImage:imgOrName];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      NSData * data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
        if (data != nil)
        {
            if(compress>=0 && data.length>compress*1024)//>400K
            {
                UIImage *image = [[UIImage alloc]initWithData:data];
                data= [image compress:compress];//压缩图片
            }
        }
        if (data || block)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                //在这里做UI操作(UI操作都要放在主线程中执行)
                if(data)
                {
                    [self image:data];
                    [Sagit.File set:cacheKey value:data];
                }
                if(block)
                {
                    block(@"url",self);
                }
            });
        }
        data=nil;
    });
    return self;
}

-(UIImageView*)pick:(OnPick)pick edit:(BOOL)yesNo
{
    return [self pick:pick edit:yesNo maxKb:256];
}
-(UIImageView*)pick:(OnPick)pick edit:(BOOL)yesNo maxKb:(NSInteger)maxKb
{
    if(pick==nil){return self;}
    [self key:@"maxKb" value:[@(maxKb) stringValue]];
    [self key:@"pickBlock" value:pick];
    //[self setPickBlock:pick];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = (id)self;
    picker.allowsEditing = yesNo;
    [self.stController presentViewController:picker animated:YES completion:nil];
    return self;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if([self key:@"picking"]){return;}
    [self key:@"picking" value:@"1"];//这里只允许一次选择一张，避免快速点击产生多选（先不开启一次性多选）
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = info[picker.allowsEditing?UIImagePickerControllerEditedImage:UIImagePickerControllerOriginalImage];
    NSData *data = [image compress:[[self key:@"maxKb"] intValue]];//[Sagit.Tool compressImage:image toByte:250000];
    OnPick event = [self key:@"pickBlock"];// (OnPick)objc_getAssociatedObject(self, &pickChar);
    if(event)
    {
        event(data,picker,info);
    }
    [Sagit delayExecute:1 onMainThread:NO block:^{
        [self key:@"picking" value:nil];
    }];
    
}
-(UIImageView *)reSize:(CGSize)maxSize
{
    self.image=[self.image reSize:maxSize];;
    return self;
}
#pragma mark 扩展属性
-(NSString *)imageName
{
    if(self.image)
    {
        return self.image.name;
    }
    return nil;
}
-(UIImageView *)image:(id)imgOrName
{
    self.image=[UIView toImage:imgOrName];
    if(CGSizeEqualToSize(CGSizeZero,self.frame.size))
    {
        self.image=[self.image reSize:STFullSize];
        [self frame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.image.size.width, self.image.size.height)];
    }
    return self;
}
@end



@implementation UIImage(ST)
static char nameChar='n';
-(NSString *)name
{
    return (NSString*)objc_getAssociatedObject(self, &nameChar);
}
-(void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, &nameChar, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(NSData*)compress:(NSInteger)maxKb
{
    // Compress by quality
    NSInteger maxLength=maxKb*1024;//转字节处理
    CGFloat quality = 1;
    NSData *data = UIImageJPEGRepresentation(self, quality);
    if (data.length < maxLength) return data;
    
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i)
    {
        quality = (max + min) / 2;
        data = UIImageJPEGRepresentation(self, quality);
        if (data.length < maxLength * 0.9) {
            min = quality;
        } else if (data.length > maxLength) {
            max = quality;
        } else {
            break;
        }
    }
    return data;
}
static char afterImageSaveBlockChar='c';
-(AfterImageSave)afterImageSaveBlock
{
    return (AfterImageSave)objc_getAssociatedObject(self, &afterImageSaveBlockChar);
}
-(void)setAfterImageSaveBlock:(AfterImageSave)afterImageSaveBlock
{
     objc_setAssociatedObject(self, &afterImageSaveBlockChar, afterImageSaveBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(void)save:(AfterImageSave)afterSaveBlock
{
    self.afterImageSaveBlock=afterSaveBlock;
    UIImageWriteToSavedPhotosAlbum(self, self, @selector(afterImageSave:error:contextInfo:),nil);
}
- (void)afterImageSave:(UIImage *)image error:(NSError *)error contextInfo:(void *)contextInfo
{
    if(self.afterImageSaveBlock)
    {
        self.afterImageSaveBlock(error);
        self.afterImageSaveBlock = nil;
    }
}
-(UIImage *)reSize:(CGSize)maxSize
{
    //[self width:maxSize.width height:maxSize.height];
    UIImage *image=self;
    if (image.size.width < maxSize.width && image.size.height < maxSize.height) return image;
    CGFloat imageW = image.size.width;
    CGFloat imageH = image.size.height;
    CGFloat k = 0.0f;
    CGSize size = CGSizeMake(maxSize.width, maxSize.height);
    if (image.size.width > maxSize.width)
    {
        k = image.size.width / maxSize.width;
        imageH = ceil(image.size.height / k);
        size = CGSizeMake(maxSize.width, imageH);
    }
    if (imageH > maxSize.height) {
        k = image.size.height / maxSize.height;
        imageW = ceil(image.size.width / k);
        size = CGSizeMake(imageW, maxSize.height);
    }
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndPDFContext();
    return image;
}
-(NSData *)data
{
   return UIImagePNGRepresentation(self);
}
@end
