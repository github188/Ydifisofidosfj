// DTRelease.h
// 
// Copyright (c) 2013 Darktt Personal Company
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//   http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#if __has_feature(objc_arc)

    #define ARC_MODE_USED
    #define DTAutorelease( expression )     expression
    #define DTRelease( expression )
    #define DTRetain( expression )          expression
    #define DTBlockCopy( expression )       expression
    #define DTBlockRelease( expression )    expression

#else

    #define ARC_MODE_NOT_USED
    #define DTAutorelease( expression )     [expression autorelease]
    #define DTRelease( expression )         [expression release]
    #define DTRetain( expression )          [expression retain]
    #define DTBlockCopy( expression )       Block_copy( expression )
    #define DTBlockRelease( expression )    Block_release( expression )

#endif