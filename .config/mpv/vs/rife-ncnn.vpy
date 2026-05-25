import vapoursynth as vs
from vapoursynth import core

clip = video_in
clip = vs.core.resize.Bicubic(clip, format=vs.RGBS, matrix_in_s="709")
clip = core.rife.RIFE(clip, model=9, factor_num=2, gpu_id=0, gpu_thread=4, tta=False, uhd=False, skip=False, sc=False)
clip = vs.core.resize.Bicubic(clip, format=vs.YUV420P10, matrix_s="709")
clip.set_output()