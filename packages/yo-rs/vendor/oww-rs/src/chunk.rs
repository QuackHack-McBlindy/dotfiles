// TODO remove out of ws_common

/// Vec having always one or two channels only
#[derive(Debug, Clone)]
pub struct ChannelsVec<T>(Vec<T>);

impl<T> ChannelsVec<T> {
    pub fn new(v: Vec<T>) -> Self {
        if v.len() > 2 || v.is_empty() {
            panic!("ChannelsVec len != 1 or 2, but got {}", v.len());
        }
        Self(v)
    }

    pub fn dimensions(&self) -> String {
        format!("ChannelsVec size {}", self.0.len())
    }

    pub(crate) fn len(&self) -> usize {
        self.0.len()
    }

    pub fn get(&self, index: usize) -> Option<&T> {
        self.0.get(index)
    }

    pub fn push(&mut self, value: T) {
        self.0.push(value)
    }

    pub fn from_iter_checked<I: IntoIterator<Item = T>>(iter: I) -> Result<Self, LengthError> {
        let vec: Vec<T> = iter.into_iter().collect();
        Self::try_from(vec)
    }
}

impl<T> Index<usize> for ChannelsVec<T> {
    type Output = T;

    fn index(&self, index: usize) -> &Self::Output {
        &self.0[index]
    }
}

impl<T> FromIterator<T> for ChannelsVec<T> {
    fn from_iter<I: IntoIterator<Item = T>>(iter: I) -> Self {
        let vec: Vec<T> = iter.into_iter().collect();
        ChannelsVec::try_from(vec).expect("Must contain 1 or 2 elements")
    }
}

impl<T> IndexMut<usize> for ChannelsVec<T> {
    fn index_mut(&mut self, index: usize) -> &mut Self::Output {
        &mut self.0[index]
    }
}

#[derive(Debug)]
pub struct LengthError;

impl<T> TryFrom<Vec<T>> for ChannelsVec<T> {
    type Error = LengthError;

    fn try_from(vec: Vec<T>) -> Result<Self, Self::Error> {
        Ok(ChannelsVec(vec))
    }
}

use std::ops::{Index, IndexMut};
use std::slice::Iter;
impl<T> ChannelsVec<T> {
    pub fn iter(&self) -> Iter<'_, T> {
        self.0.iter()
    }
}

impl<T> ChannelsVec<T> {
    pub fn first(&self) -> &T {
        &self.0[0]
    }
}

pub type ChannelsData = ChannelsVec<Vec<f32>>;
pub type ChannelsDataI16 = ChannelsVec<Vec<i16>>;

#[derive(Clone, Debug)]
pub struct Chunk {
    pub data_i16: ChannelsDataI16,
    pub data_f32: ChannelsData,
    pub rms: i16,
}

pub type ChunkType = Chunk;

impl Chunk {
    pub fn to_interleaved_channels(&self) -> Vec<i16> {
        let len = self.data_i16.first().len();
        assert!(self.data_i16.iter().all(|ch| ch.len() == len), "All channels must have the same length");

        let mut interleaved = Vec::with_capacity(len * self.data_i16.len());

        for i in 0..len {
            for ch in self.data_i16.iter() {
                interleaved.push(ch[i]);
            }
        }

        interleaved
    }
}
